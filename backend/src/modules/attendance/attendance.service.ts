import { AttendanceModel } from '../../models/attendance.model';
import { ChildModel }      from '../../models/child.model';
import { SessionModel }    from '../../models/session.model';
import { AppError }        from '../../middleware/error';
import type { AuthPayload } from '../../middleware/auth';
import { fetchMeetAttendance } from '../google/google.service';
import type { MarkAttendanceInput, SyncMeetAttendanceInput } from './attendance.schema';

const MARK_ROLES = ['therapist', 'center_head', 'lead_therapist'] as const;

export async function markAttendance(input: MarkAttendanceInput, user: AuthPayload) {
  if (!(MARK_ROLES as readonly string[]).includes(user.role)) {
    throw new AppError('FORBIDDEN', 'Only therapists and center head can mark attendance');
  }
  return AttendanceModel.create({
    ...input,
    date:      new Date(input.date),
    source:    input.source ?? 'manual',
    marked_by: user.sub,
  });
}

export async function syncMeetAttendance(input: SyncMeetAttendanceInput, user: AuthPayload) {
  if (!(MARK_ROLES as readonly string[]).includes(user.role)) {
    throw new AppError('FORBIDDEN', 'Only therapists and center head can sync attendance');
  }

  const session = await SessionModel.findById(input.session_id).lean();
  if (!session) throw new AppError('NOT_FOUND', 'Session not found');
  if (session.mode !== 'online' || !session.meeting_link) {
    throw new AppError('INVALID_INPUT', 'Session is not an online session with a meeting link');
  }

  const child = await ChildModel.findById(session.child_id).lean();
  if (!child) throw new AppError('NOT_FOUND', 'Child not found');

  const canAccess =
    user.role === 'center_head' ||
    user.role === 'lead_therapist' ||
    (user.role === 'therapist' && String(session.therapist_id) === user.sub);

  if (!canAccess) throw new AppError('FORBIDDEN', 'Access denied');

  const meetAttendance = await fetchMeetAttendance(session.meeting_link, session.scheduled_at);
  const status = meetAttendance.participantCount > 0 ? 'present' : 'absent';

  return AttendanceModel.findOneAndUpdate(
    { session_id: session._id },
    {
      $set: {
        child_id:  session.child_id,
        session_id: session._id,
        date:      session.scheduled_at,
        status,
        marked_by: user.sub,
        source:    'google_meet',
        notes:     `Google Meet participants: ${meetAttendance.participantNames.join(', ') || 'none'}`,
      },
    },
    { upsert: true, new: true },
  );
}

export async function listAttendance(childId: string, user: AuthPayload) {
  const child = await ChildModel.findById(childId).lean();
  if (!child) throw new AppError('NOT_FOUND', 'Child not found');

  const canAccess =
    user.role === 'center_head' ||
    user.role === 'lead_therapist' ||
    (user.role === 'therapist' && (child.therapists ?? []).some((t) => String(t.therapist_id) === user.sub)) ||
    (user.role === 'parent' && String(child.parent_id) === user.sub);

  if (!canAccess) throw new AppError('FORBIDDEN', 'Access denied');

  return AttendanceModel.find({ child_id: childId })
    .sort({ date: -1 })
    .limit(90)
    .lean();
}

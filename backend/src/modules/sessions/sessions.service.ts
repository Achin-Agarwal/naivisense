import { SessionModel }           from '../../models/session.model';
import { ChildModel }             from '../../models/child.model';
import { UserModel }              from '../../models/user.model';
import { AppError }               from '../../middleware/error';
import type { AuthPayload }       from '../../middleware/auth';
import { snapshotQueue }          from '../../jobs/queues';
import { syncCalendarEvent }      from '../google/google.service';
import type { CreateSessionInput, SubmitNotesInput } from './sessions.schema';

export async function createSession(input: CreateSessionInput, user: AuthPayload) {
  if (user.role !== 'therapist') {
    throw new AppError('FORBIDDEN', 'Only therapists can create sessions');
  }

  const child = input.mode === 'online'
    ? await ChildModel.findById(input.child_id).lean()
    : null;

  if (input.mode === 'online' && !child) {
    throw new AppError('NOT_FOUND', 'Child not found');
  }

  const session = await SessionModel.create({
    ...input,
    therapist_id: user.sub,
    scheduled_at: input.scheduled_at ? new Date(input.scheduled_at) : new Date(),
  });

  if (input.mode === 'online' && child) {
    const [parent, therapist] = await Promise.all([
      UserModel.findById(child.parent_id).lean(),
      UserModel.findById(user.sub).lean(),
    ]);

    const calendar = await syncCalendarEvent({
      sessionId:      session._id.toString(),
      scheduledAt:    session.scheduled_at,
      durationMin:    session.duration_min,
      childName:      child.name,
      parentEmail:    child.parent_email ?? parent?.email,
      therapistEmail: therapist?.email,
    });

    session.meeting_link       = calendar.meeting_link;
    session.calendar_event_id  = calendar.calendar_event_id;
    session.calendar_provider  = calendar.calendar_provider;
    session.calendar_synced_at = new Date();
    await session.save();
  }

  return session;
}

export async function submitNotes(sessionId: string, notes: SubmitNotesInput, user: AuthPayload) {
  if (user.role !== 'therapist') {
    throw new AppError('FORBIDDEN', 'Only therapists can submit session notes');
  }
  const session = await SessionModel.findById(sessionId);
  if (!session) throw new AppError('NOT_FOUND', 'Session not found');
  if (session.therapist_id.toString() !== user.sub) {
    throw new AppError('FORBIDDEN', 'This is not your session');
  }

  session.notes  = notes as never;
  session.status = 'completed';
  await session.save();

  await snapshotQueue.add('rebuild', { childId: session.child_id.toString() });

  return session;
}

export async function getUpcomingSessions(user: AuthPayload) {
  const now    = new Date();
  const filter =
    user.role === 'therapist'
      ? { therapist_id: user.sub, scheduled_at: { $gte: now }, status: 'scheduled' }
      : { scheduled_at: { $gte: now }, status: 'scheduled' };

  return SessionModel.find(filter).sort({ scheduled_at: 1 }).limit(20).lean();
}

export async function listSessions(childId: string, user: AuthPayload) {
  const child = await ChildModel.findById(childId).lean();
  if (!child) throw new AppError('NOT_FOUND', 'Child not found');

  const canAccess =
    user.role === 'center_head' ||
    user.role === 'lead_therapist' ||
    (user.role === 'therapist' && (child.therapists ?? []).some((t) => String(t.therapist_id) === user.sub)) ||
    (user.role === 'parent'    && String(child.parent_id)    === user.sub);

  if (!canAccess) throw new AppError('FORBIDDEN', 'Access denied');
  return SessionModel.find({ child_id: childId }).sort({ scheduled_at: -1 }).lean();
}

export async function getNextSession(childId: string, user: AuthPayload) {
  const child = await ChildModel.findById(childId).lean();
  if (!child) throw new AppError('NOT_FOUND', 'Child not found');

  const canAccess =
    user.role === 'center_head' ||
    user.role === 'lead_therapist' ||
    (user.role === 'therapist' && (child.therapists ?? []).some((t) => String(t.therapist_id) === user.sub)) ||
    (user.role === 'parent'    && String(child.parent_id)    === user.sub);

  if (!canAccess) throw new AppError('FORBIDDEN', 'Access denied');

  const now = new Date();
  const next = await SessionModel.findOne({
    child_id:     childId,
    scheduled_at: { $gte: now },
    status:       'scheduled',
  }).sort({ scheduled_at: 1 }).lean();

  return next ?? null;
}

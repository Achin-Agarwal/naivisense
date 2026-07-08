import { SessionTimingModel } from '../../models/session-timing.model';
import { UserModel } from '../../models/user.model';
import { AppError } from '../../middleware/error';
import type { AuthPayload } from '../../middleware/auth';
import type { CreateSessionTimingInput, UpdateSessionTimingInput } from './session-timings.schema';

const BUFFER_MINUTES = 10;

function timeToMinutes(time: string): number {
  const [hours, minutes] = time.split(':').map(Number);
  return hours * 60 + minutes;
}

function minutesToTime(totalMinutes: number): string {
  const wrapped = ((totalMinutes % 1440) + 1440) % 1440;
  const hours = Math.floor(wrapped / 60);
  const minutes = wrapped % 60;
  return `${String(hours).padStart(2, '0')}:${String(minutes).padStart(2, '0')}`;
}

async function resolveTherapistId(user: AuthPayload, requestedTherapistId: string | undefined): Promise<string> {
  if (user.role === 'therapist') {
    return user.sub;
  }

  if (user.role === 'center_head') {
    if (!requestedTherapistId) {
      throw new AppError('INVALID_INPUT', 'therapist_id is required when creating on behalf of a therapist');
    }
    const therapist = await UserModel.findById(requestedTherapistId).lean();
    if (!therapist || therapist.role !== 'therapist') {
      throw new AppError('NOT_FOUND', 'Therapist not found');
    }
    return requestedTherapistId;
  }

  throw new AppError('FORBIDDEN', 'Only therapists or a center head can manage session timings');
}

// 10-minute gap bhi enforce karta hai — jaise agar ek slot 11:00 pe end hota hai,
// to naya slot 11:10 se pehle start nahi ho sakta usi therapist ke liye.
async function assertNoOverlap(therapistId: string, date: Date, startTime: string, endTime: string, excludeId?: string) {
  const bufferedStart = minutesToTime(timeToMinutes(startTime) - BUFFER_MINUTES);
  const bufferedEnd   = minutesToTime(timeToMinutes(endTime)   + BUFFER_MINUTES);

  const query: Record<string, unknown> = {
    therapist_id: therapistId,
    date,
    start_time: { $lt: bufferedEnd },
    end_time: { $gt: bufferedStart },
  };
  if (excludeId) query._id = { $ne: excludeId };

  const clash = await SessionTimingModel.findOne(query).lean();
  if (clash) {
    throw new AppError('CONFLICT', `This overlaps with an existing slot, or is within the required ${BUFFER_MINUTES}-minute gap between sessions`);
  }
}

export async function createSessionTiming(input: CreateSessionTimingInput, user: AuthPayload) {
  if (input.start_time >= input.end_time) {
    throw new AppError('INVALID_INPUT', 'start_time must be before end_time');
  }

  const therapistId = await resolveTherapistId(user, input.therapist_id);
  const date = new Date(input.date);

  await assertNoOverlap(therapistId, date, input.start_time, input.end_time);

  return SessionTimingModel.create({
    therapist_id: therapistId,
    date,
    start_time: input.start_time,
    end_time: input.end_time,
    mode: input.mode,
    capacity: input.capacity,
  });
}

export async function listSessionTimings(
  therapistId: string | undefined,
  from: string | undefined,
  to: string | undefined,
) {
  const filter: Record<string, unknown> = {};
  if (therapistId) filter.therapist_id = therapistId;
  if (from || to) {
    filter.date = {
      ...(from ? { $gte: new Date(from) } : {}),
      ...(to   ? { $lte: new Date(to) }   : {}),
    };
  }
  return SessionTimingModel.find(filter).sort({ date: 1, start_time: 1 }).lean();
}

export async function updateSessionTiming(id: string, updates: UpdateSessionTimingInput, user: AuthPayload) {
  const timing = await SessionTimingModel.findById(id);
  if (!timing) throw new AppError('NOT_FOUND', 'Session timing not found');

  const canEdit = user.role === 'center_head' || (user.role === 'therapist' && String(timing.therapist_id) === user.sub);
  if (!canEdit) throw new AppError('FORBIDDEN', 'You cannot edit this session timing');

  const nextCapacity = updates.capacity ?? timing.capacity;
  if (nextCapacity < timing.booked_count) {
    throw new AppError('CONFLICT', 'capacity cannot be lower than the current booked_count');
  }

  const nextStart = updates.start_time ?? timing.start_time;
  const nextEnd   = updates.end_time   ?? timing.end_time;
  const nextDate  = updates.date ? new Date(updates.date) : timing.date;

  if (nextStart >= nextEnd) {
    throw new AppError('INVALID_INPUT', 'start_time must be before end_time');
  }

  if (updates.date || updates.start_time || updates.end_time) {
    await assertNoOverlap(String(timing.therapist_id), nextDate, nextStart, nextEnd, id);
  }

  timing.set({
    ...updates,
    ...(updates.date ? { date: nextDate } : {}),
  });
  await timing.save();
  return timing;
}

export async function deleteSessionTiming(id: string, user: AuthPayload) {
  const timing = await SessionTimingModel.findById(id).lean();
  if (!timing) throw new AppError('NOT_FOUND', 'Session timing not found');

  const canDelete = user.role === 'center_head' || (user.role === 'therapist' && String(timing.therapist_id) === user.sub);
  if (!canDelete) throw new AppError('FORBIDDEN', 'You cannot delete this session timing');

  if (timing.booked_count > 0) {
    throw new AppError('CONFLICT', 'Cannot delete a slot that already has bookings');
  }

  await SessionTimingModel.findByIdAndDelete(id);
}
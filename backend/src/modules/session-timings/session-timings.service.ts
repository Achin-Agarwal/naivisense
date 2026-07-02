import { SessionTimingModel } from '../../models/session-timing.model';
import { UserModel } from '../../models/user.model';
import { AppError } from '../../middleware/error';
import type { AuthPayload } from '../../middleware/auth';
import type { CreateSessionTimingInput, UpdateSessionTimingInput } from './session-timings.schema';

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

async function assertNoOverlap(therapistId: string, date: Date, startTime: string, endTime: string, excludeId?: string) {
  const query: Record<string, unknown> = {
    therapist_id: therapistId,
    date,
    start_time: { $lt: endTime },
    end_time: { $gt: startTime },
  };
  if (excludeId) query._id = { $ne: excludeId };

  const clash = await SessionTimingModel.findOne(query).lean();
  if (clash) {
    throw new AppError('CONFLICT', 'This overlaps with an existing session timing slot');
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

export async function updateSessionTiming(id: string, updates: UpdateSessionTimingInput, user: AuthPayload) {
  const timing = await SessionTimingModel.findById(id);
  if (!timing) throw new AppError('NOT_FOUND', 'Session timing not found');

  const canEdit = user.role === 'center_head' || (user.role === 'therapist' && String(timing.therapist_id) === user.sub);
  if (!canEdit) throw new AppError('FORBIDDEN', 'You cannot edit this session timing');

  const nextCapacity = updates.capacity ?? timing.capacity;
  if (nextCapacity < timing.booked_count) {
    throw new AppError('CONFLICT', 'capacity cannot be lower than the current booked_count');
  }

  timing.set(updates);
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
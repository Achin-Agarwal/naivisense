import { DietRequestModel }   from '../../models/diet-request.model';
import { ChildModel }          from '../../models/child.model';
import { AppError }            from '../../middleware/error';
import type { AuthPayload }    from '../../middleware/auth';
import type { CreateDietRequestInput, UpdateDietRequestInput } from './diet-requests.schema';

const REQUEST_CREATORS = ['therapist', 'center_head'] as const;

export async function createDietRequest(input: CreateDietRequestInput, user: AuthPayload) {
  if (!(REQUEST_CREATORS as readonly string[]).includes(user.role)) {
    throw new AppError('FORBIDDEN', 'Only therapists and center head can request diet plans');
  }
  return DietRequestModel.create({
    ...input,
    requested_by:      user.sub,
    requested_by_role: user.role as 'therapist' | 'center_head',
  });
}

export async function listDietRequests(user: AuthPayload, childId?: string) {
  const filter: Record<string, unknown> = {};

  if (user.role === 'dietician') {
    filter.assigned_dietician_id = user.sub;
  } else if (user.role === 'therapist') {
    filter.requested_by = user.sub;
  } else if (user.role !== 'center_head' && user.role !== 'lead_therapist') {
    throw new AppError('FORBIDDEN', 'Access denied');
  }

  if (childId) filter.child_id = childId;

  return DietRequestModel.find(filter)
    .populate('child_id', 'name')
    .populate('requested_by', 'name role')
    .populate('assigned_dietician_id', 'name')
    .sort({ created_at: -1 })
    .lean();
}

export async function updateDietRequest(id: string, updates: UpdateDietRequestInput, user: AuthPayload) {
  const request = await DietRequestModel.findById(id).lean();
  if (!request) throw new AppError('NOT_FOUND', 'Diet request not found');

  const canEdit =
    user.role === 'center_head' ||
    (user.role === 'dietician' && String(request.assigned_dietician_id) === user.sub);

  if (!canEdit) throw new AppError('FORBIDDEN', 'Access denied');

  const updated = await DietRequestModel.findByIdAndUpdate(
    id,
    { $set: updates },
    { new: true },
  );
  return updated;
}

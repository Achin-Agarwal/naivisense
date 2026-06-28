import { ConcernModel }           from '../../models/concern.model';
import { ChildModel }             from '../../models/child.model';
import { AppError }               from '../../middleware/error';
import type { AuthPayload }       from '../../middleware/auth';
import type { CreateConcernInput, UpdateConcernInput } from './concerns.schema';

const CONCERN_CREATORS = ['parent', 'therapist', 'clinical_psychologist'] as const;

export async function createConcern(input: CreateConcernInput, user: AuthPayload) {
  if (!(CONCERN_CREATORS as readonly string[]).includes(user.role)) {
    throw new AppError('FORBIDDEN', 'Only parents, therapists, and clinical psychologists can raise concerns');
  }
  return ConcernModel.create({
    ...input,
    created_by:      user.sub,
    created_by_role: user.role as 'parent' | 'therapist' | 'clinical_psychologist',
  });
}

export async function listConcerns(childId: string, status: string | undefined, user: AuthPayload) {
  const child = await ChildModel.findById(childId).lean();
  if (!child) throw new AppError('NOT_FOUND', 'Child not found');

  const canAccess =
    user.role === 'center_head' ||
    user.role === 'lead_therapist' ||
    user.role === 'clinical_psychologist' ||
    (user.role === 'therapist' && (child.therapists ?? []).some((t) => String(t.therapist_id) === user.sub)) ||
    (user.role === 'parent'    && String(child.parent_id)    === user.sub);

  if (!canAccess) throw new AppError('FORBIDDEN', 'Access denied');

  const filter: Record<string, unknown> = { child_id: childId };
  if (status === 'open' || status === 'resolved') filter.status = status;

  return ConcernModel.find(filter).sort({ created_at: -1 }).lean();
}

export async function updateConcern(id: string, updates: UpdateConcernInput, user: AuthPayload) {
  if (!['therapist', 'center_head', 'lead_therapist'].includes(user.role)) {
    throw new AppError('FORBIDDEN', 'Only therapists and center head can resolve concerns');
  }
  const patch: Record<string, unknown> = {};
  if (updates.status)     patch.status = updates.status;
  if (updates.resolution) patch.resolution = updates.resolution;
  if (updates.status === 'resolved') {
    patch.resolved_by  = user.sub;
    patch.resolved_at  = new Date();
  }
  const concern = await ConcernModel.findByIdAndUpdate(id, { $set: patch }, { new: true });
  if (!concern) throw new AppError('NOT_FOUND', 'Concern not found');
  return concern;
}

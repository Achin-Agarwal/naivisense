import { GoalModel }             from '../../models/goal.model';
import { ChildModel }            from '../../models/child.model';
import { AppError }              from '../../middleware/error';
import type { AuthPayload }      from '../../middleware/auth';
import type { CreateGoalInput, UpdateGoalInput } from './goals.schema';

export async function createGoal(input: CreateGoalInput, user: AuthPayload) {
  if (!['therapist', 'center_head', 'lead_therapist'].includes(user.role)) {
    throw new AppError('FORBIDDEN', 'Only therapists and center head can create goals');
  }
  return GoalModel.create({ ...input, created_by: user.sub });
}

export async function listGoals(childId: string, user: AuthPayload) {
  const child = await ChildModel.findById(childId).lean();
  if (!child) throw new AppError('NOT_FOUND', 'Child not found');

  const canAccess =
    user.role === 'center_head' ||
    user.role === 'lead_therapist' ||
    (user.role === 'therapist' && (child.therapists ?? []).some((t) => String(t.therapist_id) === user.sub)) ||
    (user.role === 'parent' && String(child.parent_id) === user.sub);

  if (!canAccess) throw new AppError('FORBIDDEN', 'Access denied');
  return GoalModel.find({ child_id: childId }).sort({ priority: -1, created_at: -1 }).lean();
}

export async function updateGoal(id: string, updates: UpdateGoalInput, user: AuthPayload) {
  if (!['therapist', 'center_head', 'lead_therapist'].includes(user.role)) {
    throw new AppError('FORBIDDEN', 'Only therapists and center head can update goals');
  }
  const patch: Record<string, unknown> = { ...updates };
  if (updates.target_date) patch.target_date = new Date(updates.target_date);

  // Record who accepted when status moves to accepted
  if (updates.status === 'accepted') {
    patch.accepted_by = user.sub;
    patch.accepted_at = new Date();
  }

  const goal = await GoalModel.findByIdAndUpdate(id, { $set: patch }, { new: true });
  if (!goal) throw new AppError('NOT_FOUND', 'Goal not found');
  return goal;
}

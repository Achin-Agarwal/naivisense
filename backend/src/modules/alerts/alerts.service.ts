import { AlertModel }           from '../../models/alert.model';
import { ChildModel }           from '../../models/child.model';
import { AppError }             from '../../middleware/error';
import type { AuthPayload }     from '../../middleware/auth';
import type { CreateAlertInput, UpdateAlertInput } from './alerts.schema';

const ALERT_CREATORS = ['parent', 'therapist', 'clinical_psychologist'] as const;

export async function createAlert(input: CreateAlertInput, user: AuthPayload) {
  if (!(ALERT_CREATORS as readonly string[]).includes(user.role)) {
    throw new AppError('FORBIDDEN', 'Only parents, therapists, and clinical psychologists can raise alerts');
  }
  const source = user.role as 'parent' | 'therapist' | 'clinical_psychologist';
  return AlertModel.create({ ...input, raised_by: user.sub, source });
}

export async function listAlerts(childId: string, user: AuthPayload) {
  const child = await ChildModel.findById(childId).lean();
  if (!child) throw new AppError('NOT_FOUND', 'Child not found');

  const canAccess =
    user.role === 'center_head' ||
    user.role === 'lead_therapist' ||
    user.role === 'clinical_psychologist' ||
    (user.role === 'therapist' && (child.therapists ?? []).some((t) => String(t.therapist_id) === user.sub)) ||
    (user.role === 'parent'    && String(child.parent_id)    === user.sub);

  if (!canAccess) throw new AppError('FORBIDDEN', 'Access denied');
  return AlertModel.find({ child_id: childId }).sort({ created_at: -1 }).lean();
}

export async function updateAlert(id: string, updates: UpdateAlertInput, user: AuthPayload) {
  if (!['therapist', 'center_head', 'lead_therapist'].includes(user.role)) {
    throw new AppError('FORBIDDEN', 'Only therapists and center head can update alerts');
  }
  const patch: Record<string, unknown> = {};
  if (updates.status)          patch.status          = updates.status;
  if (updates.resolution_note) patch.resolution_note = updates.resolution_note;
  if (updates.acknowledged_at) patch.acknowledged_at = new Date(updates.acknowledged_at);
  if (updates.resolved_at)     patch.resolved_at     = new Date(updates.resolved_at);
  if (updates.status === 'resolved') patch.resolved_by = user.sub;

  const alert = await AlertModel.findByIdAndUpdate(id, { $set: patch }, { new: true });
  if (!alert) throw new AppError('NOT_FOUND', 'Alert not found');
  return alert;
}

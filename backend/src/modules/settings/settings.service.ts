import { SystemSettingModel } from '../../models/system-setting.model';
import { AppError }           from '../../middleware/error';
import type { AuthPayload }   from '../../middleware/auth';

export async function getSetting(key: string, user: AuthPayload) {
  if (user.role !== 'center_head') throw new AppError('FORBIDDEN', 'Access denied');
  const setting = await SystemSettingModel.findOne({ key }).lean();
  if (!setting) throw new AppError('NOT_FOUND', `Setting '${key}' not found`);
  return setting;
}

export async function listSettings(user: AuthPayload) {
  if (user.role !== 'center_head') throw new AppError('FORBIDDEN', 'Access denied');
  return SystemSettingModel.find().sort({ key: 1 }).lean();
}

export async function upsertSetting(key: string, value: unknown, user: AuthPayload) {
  if (user.role !== 'center_head') throw new AppError('FORBIDDEN', 'Access denied');
  const setting = await SystemSettingModel.findOneAndUpdate(
    { key },
    { $set: { value, updated_by: user.sub } },
    { new: true, upsert: true },
  );
  return setting;
}

export async function deleteSetting(key: string, user: AuthPayload) {
  if (user.role !== 'center_head') throw new AppError('FORBIDDEN', 'Access denied');
  await SystemSettingModel.deleteOne({ key });
}

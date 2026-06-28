import * as SettingsService from './settings.service';
import { asyncHandler }     from '../../utils/http';
import { AppError }         from '../../middleware/error';

export const listSettings = asyncHandler(async (req, res) => {
  const settings = await SettingsService.listSettings(req.user!);
  res.json(settings);
});

export const getSetting = asyncHandler(async (req, res) => {
  const setting = await SettingsService.getSetting(req.params.key, req.user!);
  res.json(setting);
});

export const upsertSetting = asyncHandler(async (req, res) => {
  const { value } = req.body as { value?: unknown };
  if (value === undefined) throw new AppError('INVALID_INPUT', 'value is required');
  const setting = await SettingsService.upsertSetting(req.params.key, value, req.user!);
  res.json(setting);
});

export const deleteSetting = asyncHandler(async (req, res) => {
  await SettingsService.deleteSetting(req.params.key, req.user!);
  res.json({ success: true });
});

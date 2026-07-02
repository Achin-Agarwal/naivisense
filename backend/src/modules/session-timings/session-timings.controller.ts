import * as SessionTimingService from './session-timings.service';
import { CreateSessionTimingSchema, UpdateSessionTimingSchema } from './session-timings.schema';
import { asyncHandler } from '../../utils/http';

export const create = asyncHandler(async (req, res) => {
  const input = CreateSessionTimingSchema.parse(req.body);
  const timing = await SessionTimingService.createSessionTiming(input, req.user!);
  res.status(201).json(timing);
});

export const update = asyncHandler(async (req, res) => {
  const updates = UpdateSessionTimingSchema.parse(req.body);
  const timing = await SessionTimingService.updateSessionTiming(req.params.id, updates, req.user!);
  res.json(timing);
});

export const remove = asyncHandler(async (req, res) => {
  await SessionTimingService.deleteSessionTiming(req.params.id, req.user!);
  res.status(204).send();
});
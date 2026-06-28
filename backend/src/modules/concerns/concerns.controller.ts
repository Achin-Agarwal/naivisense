import * as ConcernService  from './concerns.service';
import { CreateConcernSchema, UpdateConcernSchema } from './concerns.schema';
import { AppError }          from '../../middleware/error';
import { asyncHandler }      from '../../utils/http';

export const create = asyncHandler(async (req, res) => {
  const input   = CreateConcernSchema.parse(req.body);
  const concern = await ConcernService.createConcern(input, req.user!);
  res.status(201).json(concern);
});

export const list = asyncHandler(async (req, res) => {
  const { childId, status } = req.query;
  if (!childId || typeof childId !== 'string') {
    throw new AppError('INVALID_INPUT', 'childId query param is required');
  }
  const concerns = await ConcernService.listConcerns(childId, status as string | undefined, req.user!);
  res.json(concerns);
});

export const update = asyncHandler(async (req, res) => {
  const updates = UpdateConcernSchema.parse(req.body);
  const concern = await ConcernService.updateConcern(req.params.id, updates, req.user!);
  res.json(concern);
});

import * as DietRequestService from './diet-requests.service';
import { CreateDietRequestSchema, UpdateDietRequestSchema } from './diet-requests.schema';
import { asyncHandler } from '../../utils/http';

export const create = asyncHandler(async (req, res) => {
  const input   = CreateDietRequestSchema.parse(req.body);
  const request = await DietRequestService.createDietRequest(input, req.user!);
  res.status(201).json(request);
});

export const list = asyncHandler(async (req, res) => {
  const childId  = typeof req.query.childId === 'string' ? req.query.childId : undefined;
  const requests = await DietRequestService.listDietRequests(req.user!, childId);
  res.json(requests);
});

export const update = asyncHandler(async (req, res) => {
  const updates  = UpdateDietRequestSchema.parse(req.body);
  const request  = await DietRequestService.updateDietRequest(req.params.id, updates, req.user!);
  res.json(request);
});

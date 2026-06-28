import * as GoalService  from './goals.service';
import { CreateGoalSchema, UpdateGoalSchema } from './goals.schema';
import { AppError }       from '../../middleware/error';
import { asyncHandler }   from '../../utils/http';

export const create = asyncHandler(async (req, res) => {
  const input = CreateGoalSchema.parse(req.body);
  const goal  = await GoalService.createGoal(input, req.user!);
  res.status(201).json(goal);
});

export const list = asyncHandler(async (req, res) => {
  const { childId } = req.query;
  if (!childId || typeof childId !== 'string') {
    throw new AppError('INVALID_INPUT', 'childId query param is required');
  }
  const goals = await GoalService.listGoals(childId, req.user!);
  res.json(goals);
});

export const update = asyncHandler(async (req, res) => {
  const updates = UpdateGoalSchema.parse(req.body);
  const goal    = await GoalService.updateGoal(req.params.id, updates, req.user!);
  res.json(goal);
});

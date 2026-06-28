import * as AiService  from './ai.service';
import { asyncHandler } from '../../utils/http';
import { AppError }     from '../../middleware/error';

export const generatePlan = asyncHandler(async (req, res) => {
  const { child_id, therapy_type } = req.body as { child_id?: string; therapy_type?: string };
  if (!child_id)     throw new AppError('INVALID_INPUT', 'child_id is required');
  if (!therapy_type) throw new AppError('INVALID_INPUT', 'therapy_type is required');
  const result = await AiService.generatePlan(child_id, therapy_type, req.user!);
  res.json(result);
});

export const approvePlan = asyncHandler(async (req, res) => {
  const result = await AiService.approvePlan(req.params.draftId, req.user!);
  res.json(result);
});

export const getInsights = asyncHandler(async (req, res) => {
  const { child_id } = req.body as { child_id?: string };
  if (!child_id) throw new AppError('INVALID_INPUT', 'child_id is required');
  const result = await AiService.getInsights(child_id, req.user!);
  res.json(result);
});

export const therapyPlan = asyncHandler(async (req, res) => {
  const { child_id } = req.body as { child_id?: string };
  if (!child_id) throw new AppError('INVALID_INPUT', 'child_id is required');
  const draft = await AiService.generateTherapyPlan(child_id, req.user!);
  res.status(201).json(draft);
});

export const homePlan = asyncHandler(async (req, res) => {
  const { child_id } = req.body as { child_id?: string };
  if (!child_id) throw new AppError('INVALID_INPUT', 'child_id is required');
  const draft = await AiService.generateHomePlan(child_id, req.user!);
  res.status(201).json(draft);
});

export const dietSummary = asyncHandler(async (req, res) => {
  const { child_id } = req.body as { child_id?: string };
  if (!child_id) throw new AppError('INVALID_INPUT', 'child_id is required');
  const draft = await AiService.generateDietSummary(child_id, req.user!);
  res.status(201).json(draft);
});

export const reinforcementActivities = asyncHandler(async (req, res) => {
  const { child_id } = req.body as { child_id?: string };
  if (!child_id) throw new AppError('INVALID_INPUT', 'child_id is required');
  const draft = await AiService.generateReinforcementActivities(child_id, req.user!);
  res.status(201).json(draft);
});

export const insights = asyncHandler(async (req, res) => {
  const { child_id } = req.body as { child_id?: string };
  if (!child_id) throw new AppError('INVALID_INPUT', 'child_id is required');
  const draft = await AiService.generateInsights(child_id, req.user!);
  res.status(201).json(draft);
});

export const approveDraft = asyncHandler(async (req, res) => {
  const draft = await AiService.approveDraft(req.params.id, req.user!);
  res.json(draft);
});

export const listDrafts = asyncHandler(async (req, res) => {
  const { child_id } = req.query;
  if (!child_id || typeof child_id !== 'string') {
    throw new AppError('INVALID_INPUT', 'child_id query param is required');
  }
  const drafts = await AiService.listDrafts(child_id, req.user!);
  res.json(drafts);
});

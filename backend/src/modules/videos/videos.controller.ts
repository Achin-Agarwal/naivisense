import * as VideoService from './videos.service';
import { CreateVideoSchema, UpdateVideoSchema, AssignVideoSchema } from './videos.schema';
import { AppError }     from '../../middleware/error';
import { asyncHandler } from '../../utils/http';

export const create = asyncHandler(async (req, res) => {
  if (!req.file) throw new AppError('INVALID_INPUT', 'Video file is required');
  const input = CreateVideoSchema.parse(req.body);
  const video = await VideoService.createVideo(input, req.file, req.user!);
  res.status(201).json(video);
});

export const list = asyncHandler(async (req, res) => {
  const { childId, category } = req.query;
  if (!childId || typeof childId !== 'string') {
    throw new AppError('INVALID_INPUT', 'childId query param is required');
  }
  const videos = await VideoService.listVideos(childId, category as string | undefined, req.user!);
  res.json(videos);
});

export const getOne = asyncHandler(async (req, res) => {
  const video = await VideoService.getVideo(req.params.id, req.user!);
  res.json(video);
});

export const update = asyncHandler(async (req, res) => {
  const updates = UpdateVideoSchema.parse(req.body);
  const video   = await VideoService.updateVideo(req.params.id, updates, req.user!);
  res.json(video);
});

export const remove = asyncHandler(async (req, res) => {
  await VideoService.deleteVideo(req.params.id, req.user!);
  res.status(204).send();
});

export const assign = asyncHandler(async (req, res) => {
  const { child_id } = AssignVideoSchema.parse(req.body);
  const video = await VideoService.assignVideo(req.params.id, child_id, req.user!);
  res.status(201).json(video);
});

export const deassign = asyncHandler(async (req, res) => {
  const video = await VideoService.deassignVideo(req.params.id, req.params.childId, req.user!);
  res.json(video);
});
import * as VideoService from './videos.service';
import { CreateVideoSchema, UpdateVideoSchema } from './videos.schema';
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

import * as ReviewService  from './reviews.service';
import { CreateReviewSchema, UpdateReviewSchema } from './reviews.schema';
import { AppError }         from '../../middleware/error';
import { asyncHandler }     from '../../utils/http';

export const create = asyncHandler(async (req, res) => {
  const input  = CreateReviewSchema.parse(req.body);
  const review = await ReviewService.createReview(input, req.user!);
  res.status(201).json(review);
});

export const list = asyncHandler(async (req, res) => {
  const { childId } = req.query;
  if (!childId || typeof childId !== 'string') {
    throw new AppError('INVALID_INPUT', 'childId query param is required');
  }
  const reviews = await ReviewService.listReviews(childId, req.user!);
  res.json(reviews);
});

export const update = asyncHandler(async (req, res) => {
  const updates = UpdateReviewSchema.parse(req.body);
  const review  = await ReviewService.updateReview(req.params.id, updates, req.user!);
  res.json(review);
});

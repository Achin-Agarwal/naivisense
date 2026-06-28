import { ReviewModel }           from '../../models/review.model';
import { ChildModel }            from '../../models/child.model';
import { AppError }              from '../../middleware/error';
import type { AuthPayload }      from '../../middleware/auth';
import type { CreateReviewInput, UpdateReviewInput } from './reviews.schema';

export async function createReview(input: CreateReviewInput, user: AuthPayload) {
  if (!['therapist', 'center_head', 'lead_therapist'].includes(user.role)) {
    throw new AppError('FORBIDDEN', 'Only therapists and center head can create reviews');
  }
  return ReviewModel.create({
    ...input,
    created_by:   user.sub,
    period_start: new Date(input.period_start),
    period_end:   new Date(input.period_end),
  });
}

export async function listReviews(childId: string, user: AuthPayload) {
  const child = await ChildModel.findById(childId).lean();
  if (!child) throw new AppError('NOT_FOUND', 'Child not found');

  const canAccess =
    user.role === 'center_head' ||
    user.role === 'lead_therapist' ||
    (user.role === 'therapist' && (child.therapists ?? []).some((t) => String(t.therapist_id) === user.sub)) ||
    (user.role === 'parent' && String(child.parent_id) === user.sub);

  if (!canAccess) throw new AppError('FORBIDDEN', 'Access denied');

  // Parents only see published reviews
  const filter: Record<string, unknown> = { child_id: childId };
  if (user.role === 'parent') filter.status = 'published';

  return ReviewModel.find(filter).sort({ period_start: -1 }).lean();
}

export async function updateReview(id: string, updates: UpdateReviewInput, user: AuthPayload) {
  if (!['therapist', 'center_head', 'lead_therapist'].includes(user.role)) {
    throw new AppError('FORBIDDEN', 'Only therapists and center head can update reviews');
  }
  const review = await ReviewModel.findByIdAndUpdate(id, { $set: updates }, { new: true });
  if (!review) throw new AppError('NOT_FOUND', 'Review not found');
  return review;
}

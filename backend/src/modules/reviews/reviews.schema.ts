import { z } from 'zod';

export const CreateReviewSchema = z.object({
  child_id:          z.string().length(24),
  review_type:       z.enum(['monthly', 'quarterly']),
  period_start:      z.string().datetime({ offset: true }),
  period_end:        z.string().datetime({ offset: true }),
  text_observations: z.string().min(1).max(5000),
  video_ids:         z.array(z.string().length(24)).default([]),
  assessment_id:     z.string().length(24).optional(),
});

export const UpdateReviewSchema = z.object({
  text_observations: z.string().min(1).max(5000).optional(),
  admin_notes:       z.string().max(3000).optional(),
  status:            z.enum(['draft', 'published']).optional(),
  video_ids:         z.array(z.string().length(24)).optional(),
});

export type CreateReviewInput = z.infer<typeof CreateReviewSchema>;
export type UpdateReviewInput = z.infer<typeof UpdateReviewSchema>;

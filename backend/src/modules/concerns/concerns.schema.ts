import { z } from 'zod';

export const CreateConcernSchema = z.object({
  child_id:    z.string().length(24),
  category:    z.enum(['tantrum', 'behavior', 'health', 'regression', 'activity', 'other']),
  description: z.string().min(1).max(2000),
});

export const UpdateConcernSchema = z.object({
  status:     z.enum(['open', 'resolved']).optional(),
  resolution: z.string().max(2000).optional(),
});

export type CreateConcernInput = z.infer<typeof CreateConcernSchema>;
export type UpdateConcernInput = z.infer<typeof UpdateConcernSchema>;

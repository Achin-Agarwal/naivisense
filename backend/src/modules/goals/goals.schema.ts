import { z } from 'zod';

export const CreateGoalSchema = z.object({
  child_id:    z.string().length(24),
  title:       z.string().min(1).max(200).trim(),
  description: z.string().max(2000).optional(),
  priority:    z.number().int().min(0).default(0),
  target_date: z.string().datetime({ offset: true }).optional(),
});

export const UpdateGoalSchema = z.object({
  title:       z.string().min(1).max(200).trim().optional(),
  description: z.string().max(2000).optional(),
  priority:    z.number().int().min(0).optional(),
  status:      z.enum(['proposed', 'accepted', 'active', 'completed', 'paused']).optional(),
  target_date: z.string().datetime({ offset: true }).optional(),
});

export type CreateGoalInput = z.infer<typeof CreateGoalSchema>;
export type UpdateGoalInput = z.infer<typeof UpdateGoalSchema>;

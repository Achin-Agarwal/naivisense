import { z } from 'zod';

export const CreateDietRequestSchema = z.object({
  child_id:               z.string().length(24),
  reason:                 z.string().min(1).max(2000).trim(),
  assigned_dietician_id:  z.string().length(24).optional(),
  notes:                  z.string().max(2000).optional(),
});

export const UpdateDietRequestSchema = z.object({
  status:                 z.enum(['requested', 'accepted', 'in_progress', 'completed', 'cancelled']).optional(),
  assigned_dietician_id:  z.string().length(24).optional(),
  notes:                  z.string().max(2000).optional(),
});

export type CreateDietRequestInput = z.infer<typeof CreateDietRequestSchema>;
export type UpdateDietRequestInput = z.infer<typeof UpdateDietRequestSchema>;

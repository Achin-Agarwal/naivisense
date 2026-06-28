import { z } from 'zod';

export const CreateAlertSchema = z.object({
  child_id:             z.string().length(24),
  type:                 z.enum(['fever', 'regression', 'aggression', 'seizure', 'sleep_issue', 'injury', 'emotional_stress', 'other']),
  description:          z.string().min(1).max(1000),
  severity:             z.enum(['low', 'medium', 'high']),
  priority:             z.enum(['normal', 'high']).default('normal'),
  category:             z.enum(['tantrum', 'behavior', 'health', 'regression', 'activity', 'video_review', 'other']).default('other'),
  weekly_tracking_date: z.string().datetime({ offset: true }).optional(),
  linked_video_id:      z.string().length(24).optional(),
});

export const UpdateAlertSchema = z.object({
  status:          z.enum(['open', 'seen', 'resolved']).optional(),
  resolution_note: z.string().max(2000).optional(),
  acknowledged_at: z.string().datetime({ offset: true }).optional(),
  resolved_at:     z.string().datetime({ offset: true }).optional(),
});

export type CreateAlertInput = z.infer<typeof CreateAlertSchema>;
export type UpdateAlertInput = z.infer<typeof UpdateAlertSchema>;

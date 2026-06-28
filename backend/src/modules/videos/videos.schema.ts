import { z } from 'zod';

export const CreateVideoSchema = z.object({
  child_id:         z.string().length(24),
  title:            z.string().min(1).max(200).trim(),
  description:      z.string().max(2000).optional(),
  category:         z.enum(['concern', 'improvement', 'session', 'review', 'clinical_observation', 'education']),
  visibility:       z.enum(['internal', 'parent_visible']).default('internal'),
  linked_alert_id:  z.string().length(24).optional(),
  linked_concern_id:z.string().length(24).optional(),
  linked_review_id: z.string().length(24).optional(),
});

export const UpdateVideoSchema = z.object({
  title:            z.string().min(1).max(200).trim().optional(),
  description:      z.string().max(2000).optional(),
  visibility:       z.enum(['internal', 'parent_visible']).optional(),
  linked_alert_id:  z.string().length(24).optional(),
  linked_concern_id:z.string().length(24).optional(),
  linked_review_id: z.string().length(24).optional(),
});

export type CreateVideoInput = z.infer<typeof CreateVideoSchema>;
export type UpdateVideoInput = z.infer<typeof UpdateVideoSchema>;

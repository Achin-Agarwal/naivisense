import { z } from 'zod';

export const CreateNotificationSchema = z.object({
  user_id: z.string().length(24),
  type:    z.enum(['session_reminder', 'alert_raised', 'plan_updated', 'review_published', 'general']),
  title:   z.string().min(1).max(200),
  body:    z.string().min(1).max(2000),
  data:    z.record(z.unknown()).optional(),
});

export type CreateNotificationInput = z.infer<typeof CreateNotificationSchema>;

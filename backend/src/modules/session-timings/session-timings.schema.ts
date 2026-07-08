import { z } from 'zod';

const TIME_REGEX = /^([01]\d|2[0-3]):([0-5]\d)$/;

export const CreateSessionTimingSchema = z.object({
  therapist_id: z.string().length(24).optional(),
  date: z.string().datetime({ offset: true }),
  start_time: z.string().regex(TIME_REGEX),
  end_time: z.string().regex(TIME_REGEX),
  mode: z.enum(['online', 'offline']),
  capacity: z.number().int().min(1),
});

export const UpdateSessionTimingSchema = z.object({
  date: z.string().datetime({ offset: true }).optional(),
  start_time: z.string().regex(TIME_REGEX).optional(),
  end_time: z.string().regex(TIME_REGEX).optional(),
  mode: z.enum(['online', 'offline']).optional(),
  capacity: z.number().int().min(1).optional(),
});

export type CreateSessionTimingInput = z.infer<typeof CreateSessionTimingSchema>;
export type UpdateSessionTimingInput = z.infer<typeof UpdateSessionTimingSchema>;
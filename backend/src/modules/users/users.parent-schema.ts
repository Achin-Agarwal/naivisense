import { z } from 'zod';

export const EnrollParentSchema = z.object({
  name:     z.string().min(2).max(100).trim(),
  phone:    z.string().min(10),
  email:    z.string().email().optional(),
  password: z.string().min(8),
});

export type EnrollParentInput = z.infer<typeof EnrollParentSchema>;

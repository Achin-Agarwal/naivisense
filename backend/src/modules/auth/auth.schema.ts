import { z } from 'zod';

export const RegisterSchema = z.object({
  name:     z.string().min(2).max(100).trim(),
  phone:    z.string().regex(/^\+?[1-9]\d{9,14}$/, 'Invalid phone number'),
  password: z.string().min(8).max(100),
  role:     z.enum(['center_head', 'therapist', 'lead_therapist', 'parent', 'dietician', 'clinical_psychologist']),
});

export const LoginSchema = z.object({
  phone:    z.string(),
  password: z.string(),
});

export const RefreshSchema = z.object({
  refreshToken: z.string().optional(),
  refresh_token: z.string().optional(),
}).transform((value, ctx) => {
  const token = value.refreshToken ?? value.refresh_token;
  if (!token) {
    ctx.addIssue({ code: z.ZodIssueCode.custom, message: 'refreshToken is required' });
    return z.NEVER;
  }
  return { refreshToken: token };
});

export type RegisterInput = z.infer<typeof RegisterSchema>;
export type LoginInput    = z.infer<typeof LoginSchema>;

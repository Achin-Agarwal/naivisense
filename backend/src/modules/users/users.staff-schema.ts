import { z } from 'zod';

export const EnrollStaffSchema = z.object({
  name:             z.string().min(2).max(100).trim(),
  phone:            z.string().min(10),
  email:            z.string().email().optional(),
  password:         z.string().min(8),
  role:             z.enum(['lead_therapist', 'dietician', 'clinical_psychologist']),
  qualification:    z.string().optional(),
  years_experience: z.number().min(0).default(0),
});

export type EnrollStaffInput = z.infer<typeof EnrollStaffSchema>;

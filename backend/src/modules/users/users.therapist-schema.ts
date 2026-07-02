import { z } from 'zod';

export const EnrollTherapistSchema = z.object({
  // Account
  name:     z.string().min(2).max(100).trim(),
  phone:    z.string().min(10),
  email:    z.string().email().optional(),
  password: z.string().min(8),

  // Profile
  dob:                 z.string().optional(),
  gender:              z.enum(['male', 'female', 'other']).optional(),
  qualification:       z.string().min(1),
  license_number:      z.string().optional(),
  years_experience:    z.number().min(0).default(0),
  certifications:      z.array(z.string()).default([]),
  workplace_type:      z.enum(['clinic', 'hospital', 'freelance', 'ngo']).default('clinic'),
  organization_name:   z.string().optional(),
  conditions_handled:  z.array(z.string()).default([]),
  therapy_methods:     z.array(z.string()).min(1, 'Select at least one therapy method'),
  age_groups:          z.array(z.string()).default([]),
  available_days:      z.array(z.string()).default([]),
  session_modes:       z.array(z.string()).default([]),
  session_duration:    z.number().min(15).max(120).default(45),
  identity_proof_type: z.enum(['aadhar', 'pan', 'passport', 'driving_license']).optional(),
  mail_credentials: z.object({
  smtp_email: z.string().email(),

  smtp_password: z.string().min(8),

  provider: z.enum(['gmail', 'outlook']).default('gmail'),
}),
});

export type EnrollTherapistInput = z.infer<typeof EnrollTherapistSchema>;

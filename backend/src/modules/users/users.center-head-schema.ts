import { z } from "zod";

export const EnrollCenterHeadSchema = z.object({
  // Account Details
  name: z.string().min(2).max(100).trim(),
  phone: z.string().min(10),
  email: z.string().email(),
  password: z.string().min(8),

  // Center Profile
  center_name: z.string().min(2, "Center name is required"),

  // SMTP Configuration
  smtp_credentials: z.object({
    smtp_host: z.string().min(1, "SMTP host is required"),

    smtp_port: z
      .number()
      .int()
      .min(1)
      .max(65535)
      .default(587),

    smtp_secure: z.boolean().default(false),

    smtp_user: z
      .string()
      .email("SMTP username must be a valid email"),

    smtp_password: z
      .string()
      .min(8, "SMTP password must be at least 8 characters"),
  }),
});

export type EnrollCenterHeadInput = z.infer<
  typeof EnrollCenterHeadSchema
>;
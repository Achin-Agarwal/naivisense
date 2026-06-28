import { z } from 'zod';

const DEV_AI_TOKEN = 'dev-token-placeholder-32chars!!';

const envSchema = z.object({
  NODE_ENV:              z.enum(['development', 'production', 'test']).default('development'),
  PORT:                  z.coerce.number().default(8000),
  MONGO_URL:             z.string().min(1),
  REDIS_URL:             z.string().min(1),
  JWT_ACCESS_SECRET:     z.string().min(32),
  JWT_REFRESH_SECRET:    z.string().min(32),
  ACCESS_TOKEN_EXPIRES:  z.string().default('15m'),
  REFRESH_TOKEN_EXPIRES: z.string().default('7d'),
  CLOUDINARY_CLOUD_NAME: z.string().optional(),
  CLOUDINARY_API_KEY:    z.string().optional(),
  CLOUDINARY_API_SECRET: z.string().optional(),
  AI_SERVICE_URL:        z.string().default('http://localhost:8001'),
  AI_SERVICE_TOKEN:      z.string().min(16).default(DEV_AI_TOKEN),
  ALLOWED_ORIGIN:        z.string().default('*'),
  GOOGLE_CALENDAR_ID:    z.string().default('primary'),
  GOOGLE_CLIENT_EMAIL:   z.string().optional(),
  GOOGLE_PRIVATE_KEY:    z.string().optional(),
  GOOGLE_IMPERSONATE_EMAIL: z.string().optional(),
  GOOGLE_CLIENT_ID:      z.string().optional(),
  GOOGLE_CLIENT_SECRET:  z.string().optional(),
  GOOGLE_REFRESH_TOKEN:  z.string().optional(),
}).superRefine((value, ctx) => {
  if (value.NODE_ENV === 'production' && value.AI_SERVICE_TOKEN === DEV_AI_TOKEN) {
    ctx.addIssue({
      code: z.ZodIssueCode.custom,
      path: ['AI_SERVICE_TOKEN'],
      message: 'AI_SERVICE_TOKEN must be set to a real secret in production',
    });
  }
});

const parsed = envSchema.safeParse(process.env);
if (!parsed.success) {
  console.error('❌ Invalid environment variables:', parsed.error.format());
  process.exit(1);
}

export const env = parsed.data;

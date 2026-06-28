import rateLimit from 'express-rate-limit';
import type { Request } from 'express';

const rateLimitMessage = (message: string) => ({
  error: { code: 'RATE_LIMITED', message, retryable: true },
});

export const generalRateLimit = rateLimit({
  windowMs:        60 * 1000,
  max:             60,
  standardHeaders: true,
  legacyHeaders:   false,
  message:         rateLimitMessage('Too many requests. Try again shortly.'),
});

export const authRateLimit = rateLimit({
  windowMs:        15 * 60 * 1000,
  max:             process.env.NODE_ENV === 'test' ? 1000 : 5,
  standardHeaders: true,
  legacyHeaders:   false,
  message:         rateLimitMessage('Too many login attempts. Try again in 15 minutes.'),
});

export const uploadRateLimit = rateLimit({
  windowMs:        60 * 1000,
  max:             process.env.NODE_ENV === 'test' ? 1000 : 5,
  standardHeaders: true,
  legacyHeaders:   false,
  message:         rateLimitMessage('Too many uploads. Try again shortly.'),
});

export const aiRateLimit = rateLimit({
  windowMs:        60 * 1000,
  max:             process.env.NODE_ENV === 'test' ? 1000 : 10,
  keyGenerator:    (req: Request) => req.user?.sub ?? req.ip ?? 'anonymous',
  standardHeaders: true,
  legacyHeaders:   false,
  message:         rateLimitMessage('Too many AI requests. Try again shortly.'),
});

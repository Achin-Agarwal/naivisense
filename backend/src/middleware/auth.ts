import { Request, Response, NextFunction } from 'express';
import jwt                                  from 'jsonwebtoken';
import { env }                              from '../config/env';

export interface AuthPayload {
  sub:  string;
  role: 'center_head' | 'therapist' | 'lead_therapist' | 'parent' | 'dietician' | 'clinical_psychologist';
  iat:  number;
  exp:  number;
}

declare global {
  namespace Express {
    interface Request { user?: AuthPayload }
  }
}

export function requireAuth(req: Request, res: Response, next: NextFunction): void {
  const header = req.headers.authorization;
  if (!header?.startsWith('Bearer ')) {
    res.status(401).json(apiError('UNAUTHORIZED', 'Authentication required'));
    return;
  }
  try {
    req.user = jwt.verify(header.slice(7), env.JWT_ACCESS_SECRET) as AuthPayload;
    next();
  } catch {
    res.status(401).json(apiError('UNAUTHORIZED', 'Token expired or invalid'));
  }
}

export function apiError(code: string, message: string, details?: unknown) {
  return {
    error: { code, message, details: details ?? null, retryable: false },
  };
}

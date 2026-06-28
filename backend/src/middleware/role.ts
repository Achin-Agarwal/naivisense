import { Request, Response, NextFunction } from 'express';
import { apiError }                         from './auth';

type Role = 'center_head' | 'therapist' | 'lead_therapist' | 'parent' | 'dietician' | 'clinical_psychologist';

export function requireRole(...roles: Role[]) {
  return (req: Request, res: Response, next: NextFunction): void => {
    if (!req.user || !roles.includes(req.user.role as Role)) {
      res.status(403).json(apiError('FORBIDDEN', 'Insufficient permissions'));
      return;
    }
    next();
  };
}

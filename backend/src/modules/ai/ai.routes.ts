import { Router }      from 'express';
import { requireAuth } from '../../middleware/auth';
import { requireRole } from '../../middleware/role';
import { aiRateLimit } from '../../middleware/rate-limit';
import * as Ctrl       from './ai.controller';

const router = Router();
router.use(requireAuth);
router.use(aiRateLimit);

// ── Legacy routes (preserved for backwards compatibility) ─────────────────
router.post('/plan',                  requireRole('therapist'), Ctrl.generatePlan);
router.post('/plan/:draftId/approve', requireRole('therapist', 'center_head'), Ctrl.approvePlan);
router.post('/insights',              requireRole('therapist', 'center_head'), Ctrl.getInsights);

// ── New Gemini-powered routes ─────────────────────────────────────────────
router.post('/therapy-plan',
  requireRole('therapist', 'center_head', 'lead_therapist'),
  Ctrl.therapyPlan,
);
router.post('/home-plan',
  requireRole('therapist', 'center_head'),
  Ctrl.homePlan,
);
router.post('/diet-summary',
  requireRole('dietician', 'center_head', 'therapist'),
  Ctrl.dietSummary,
);
router.post('/reinforcement-activities',
  requireRole('therapist', 'center_head', 'lead_therapist'),
  Ctrl.reinforcementActivities,
);
router.post('/insights-v2',
  requireRole('therapist', 'center_head', 'lead_therapist'),
  Ctrl.insights,
);

// ── Draft management ──────────────────────────────────────────────────────
router.get('/drafts',        requireRole('therapist', 'center_head', 'dietician', 'lead_therapist'), Ctrl.listDrafts);
router.patch('/drafts/:id/approve', requireRole('therapist', 'center_head', 'dietician'), Ctrl.approveDraft);

export default router;

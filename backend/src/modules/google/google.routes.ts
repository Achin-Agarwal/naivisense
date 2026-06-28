import { Router }      from 'express';
import { requireAuth } from '../../middleware/auth';
import { requireRole } from '../../middleware/role';
import { asyncHandler } from '../../utils/http';
import * as GoogleService from './google.service';

const router = Router();
router.use(requireAuth);

// POST /api/v1/google/meet  — create a Meet link for a session
router.post(
  '/meet',
  requireRole('center_head', 'therapist'),
  asyncHandler(async (req, res) => {
    const { sessionId } = req.body as { sessionId: string };
    const link = await GoogleService.createMeetingLink(sessionId);
    res.json({ meeting_link: link });
  }),
);

// POST /api/v1/google/calendar — sync a session to Google Calendar
router.post(
  '/calendar',
  requireRole('center_head', 'therapist'),
asyncHandler(async (req, res) => {
    const event = await GoogleService.syncCalendarEvent(req.body);
    res.json(event);
  }),
);

export default router;

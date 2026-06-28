import { Router }      from 'express';
import { requireAuth } from '../../middleware/auth';
import { requireRole } from '../../middleware/role';
import * as Ctrl       from './attendance.controller';

const router = Router();
router.use(requireAuth);

router.post('/', requireRole('therapist', 'center_head', 'lead_therapist'), Ctrl.mark);
router.post('/google-meet', requireRole('therapist', 'center_head', 'lead_therapist'), Ctrl.syncMeet);
router.get('/',  Ctrl.list);

export default router;

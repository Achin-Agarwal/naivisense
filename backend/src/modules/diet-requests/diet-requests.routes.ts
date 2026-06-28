import { Router }      from 'express';
import { requireAuth } from '../../middleware/auth';
import { requireRole } from '../../middleware/role';
import * as Ctrl       from './diet-requests.controller';

const router = Router();
router.use(requireAuth);

router.post('/',     requireRole('therapist', 'center_head'),                              Ctrl.create);
router.get('/',      requireRole('therapist', 'center_head', 'dietician', 'lead_therapist'), Ctrl.list);
router.patch('/:id', requireRole('center_head', 'dietician'),                              Ctrl.update);

export default router;

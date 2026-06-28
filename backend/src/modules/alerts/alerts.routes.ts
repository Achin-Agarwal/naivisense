import { Router }      from 'express';
import { requireAuth } from '../../middleware/auth';
import { requireRole } from '../../middleware/role';
import * as Ctrl       from './alerts.controller';

const router = Router();
router.use(requireAuth);

router.post('/',      requireRole('parent', 'therapist', 'clinical_psychologist'), Ctrl.create);
router.get('/',       Ctrl.list);
router.patch('/:id',  requireRole('therapist', 'center_head', 'lead_therapist'), Ctrl.update);

export default router;

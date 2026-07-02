import { Router } from 'express';
import { requireAuth } from '../../middleware/auth';
import { requireRole } from '../../middleware/role';
import * as Ctrl from './session-timings.controller';

const router = Router();

router.use(requireAuth);



router.post('/', requireRole('therapist', 'center_head'), Ctrl.create);
router.patch('/:id', requireRole('therapist', 'center_head'), Ctrl.update);
router.delete('/:id', requireRole('therapist', 'center_head'), Ctrl.remove);

export default router;
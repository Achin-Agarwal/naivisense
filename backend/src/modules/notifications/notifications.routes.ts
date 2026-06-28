import { Router }      from 'express';
import { requireAuth } from '../../middleware/auth';
import { requireRole } from '../../middleware/role';
import * as Ctrl       from './notifications.controller';

const router = Router();
router.use(requireAuth);

router.post('/',        requireRole('center_head'), Ctrl.create);
router.get('/',         Ctrl.list);
router.patch('/:id/read', Ctrl.markRead);

export default router;

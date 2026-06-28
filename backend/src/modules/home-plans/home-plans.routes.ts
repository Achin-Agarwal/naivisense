import { Router }      from 'express';
import { requireAuth } from '../../middleware/auth';
import { requireRole } from '../../middleware/role';
import { uploadRateLimit } from '../../middleware/rate-limit';
import { upload }      from '../../middleware/upload';
import * as Ctrl       from './home-plans.controller';

const router = Router();
router.use(requireAuth);

router.post('/',                                          requireRole('therapist'), Ctrl.create);
router.get('/active',                                     Ctrl.getActive);
router.post('/:id/tasks/:taskId/log', requireRole('parent'), uploadRateLimit, upload.single('image'), Ctrl.logTask);

export default router;

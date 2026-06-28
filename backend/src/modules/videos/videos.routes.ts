import { Router }      from 'express';
import { requireAuth } from '../../middleware/auth';
import { requireRole } from '../../middleware/role';
import { uploadRateLimit } from '../../middleware/rate-limit';
import { uploadVideo } from '../../middleware/upload';
import * as Ctrl       from './videos.controller';

const router = Router();
router.use(requireAuth);

router.post(
  '/',
  requireRole('parent', 'therapist', 'clinical_psychologist', 'center_head'),
  uploadRateLimit,
  uploadVideo.single('video'),
  Ctrl.create,
);

router.get('/',     Ctrl.list);
router.get('/:id',  Ctrl.getOne);

router.patch(
  '/:id',
  requireRole('parent', 'therapist', 'clinical_psychologist', 'center_head'),
  Ctrl.update,
);

export default router;

import { Router }       from 'express';
import { requireAuth }  from '../../middleware/auth';
import { requireRole }  from '../../middleware/role';
import * as Ctrl        from './sessions.controller';

const router = Router();
router.use(requireAuth);

router.post('/',              requireRole('therapist'), Ctrl.create);
router.get('/upcoming',       Ctrl.upcoming);
router.get('/next',           Ctrl.nextSession);
router.get('/',               Ctrl.list);
router.post('/:id/notes',     requireRole('therapist'), Ctrl.submitNotes);
router.patch(
    "/:id",
    requireRole("therapist"),
    Ctrl.update
);
router.delete(
  "/:id",
  requireRole("therapist"),
  Ctrl.cancel
);

export default router;

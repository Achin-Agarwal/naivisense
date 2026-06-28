import { Router }      from 'express';
import { requireAuth } from '../../middleware/auth';
import { requireRole } from '../../middleware/role';
import * as Ctrl       from './settings.controller';

const router = Router();
router.use(requireAuth);
router.use(requireRole('center_head'));

router.get('/',          Ctrl.listSettings);
router.get('/:key',      Ctrl.getSetting);
router.put('/:key',      Ctrl.upsertSetting);
router.delete('/:key',   Ctrl.deleteSetting);

export default router;

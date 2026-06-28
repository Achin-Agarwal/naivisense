import { Router }      from 'express';
import { requireAuth } from '../../middleware/auth';
import { requireRole } from '../../middleware/role';
import * as Ctrl       from './rag.controller';

const router = Router();
router.use(requireAuth);

router.post('/',       requireRole('center_head'), Ctrl.addDocument);
router.get('/',        requireRole('center_head', 'therapist', 'lead_therapist'), Ctrl.listDocuments);
router.get('/chunks',  requireRole('center_head', 'therapist', 'lead_therapist', 'dietician'), Ctrl.retrieve);

export default router;

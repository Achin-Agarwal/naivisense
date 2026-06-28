import { Router }      from 'express';
import { requireAuth } from '../../middleware/auth';
import { requireRole } from '../../middleware/role';
import * as Ctrl       from './payments.controller';

const router = Router();
router.use(requireAuth);

router.get('/summary', requireRole('center_head'), Ctrl.getPaymentSummary);
router.get('/',        requireRole('center_head', 'therapist', 'lead_therapist', 'parent'), Ctrl.listPayments);
router.post('/',       requireRole('center_head', 'parent'), Ctrl.createPayment);
router.patch('/:id/status', requireRole('center_head'), Ctrl.updatePaymentStatus);

export default router;

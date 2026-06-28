import { Router }      from 'express';
import { requireAuth } from '../../middleware/auth';
import { requireRole } from '../../middleware/role';
import { aiRateLimit } from '../../middleware/rate-limit';
import * as Ctrl       from './chatbot.controller';

const router = Router();
router.use(requireAuth);

router.get('/',                         requireRole('parent', 'center_head'), Ctrl.listThreads);
router.post('/thread',                  requireRole('parent', 'center_head'), Ctrl.getOrCreateThread);
router.get('/thread/:id/messages',      requireRole('parent', 'center_head'), Ctrl.getHistory);
router.post('/thread/:id/messages',     requireRole('parent', 'center_head'), aiRateLimit, Ctrl.sendMessage);
router.patch('/thread/:id/close',       requireRole('parent', 'center_head'), Ctrl.closeThread);

export default router;

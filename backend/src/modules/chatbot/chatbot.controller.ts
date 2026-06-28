import * as ChatbotService from './chatbot.service';
import { asyncHandler }    from '../../utils/http';
import { AppError }        from '../../middleware/error';

export const listThreads = asyncHandler(async (req, res) => {
  const threads = await ChatbotService.listThreads(req.user!);
  res.json(threads);
});

export const getOrCreateThread = asyncHandler(async (req, res) => {
  const { child_id } = req.body as { child_id?: string };
  const thread = await ChatbotService.getOrCreateThread(req.user!.sub, child_id);
  res.json(thread);
});

export const getHistory = asyncHandler(async (req, res) => {
  const messages = await ChatbotService.getThreadHistory(req.params.id, req.user!);
  res.json(messages);
});

export const sendMessage = asyncHandler(async (req, res) => {
  const { message } = req.body as { message?: string };
  if (!message || message.trim().length === 0) {
    throw new AppError('INVALID_INPUT', 'message is required');
  }
  const reply = await ChatbotService.sendMessage(req.params.id, message.trim(), req.user!);
  res.json(reply);
});

export const closeThread = asyncHandler(async (req, res) => {
  await ChatbotService.closeThread(req.params.id, req.user!);
  res.json({ success: true });
});

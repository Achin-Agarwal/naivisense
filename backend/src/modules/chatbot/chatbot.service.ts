import { ChatThreadModel }  from '../../models/chat-thread.model';
import { ChatMessageModel } from '../../models/chat-message.model';
import { ChildModel }       from '../../models/child.model';
import { AppError }         from '../../middleware/error';
import { generateText }     from '../../config/gemini';
import type { AuthPayload } from '../../middleware/auth';

const SYSTEM_PROMPT = `You are NaiviSense AI, a helpful assistant for parents of children with special needs.
You provide guidance on therapy activities, behavioral strategies, home routines, diet, and general support.
Be empathetic, practical, and clear. If the parent describes a medical emergency, advise seeking immediate medical help.
Do not diagnose conditions. Keep responses concise (under 300 words unless asked for more detail).`;

export async function getOrCreateThread(parentId: string, childId?: string) {
  const existing = await ChatThreadModel.findOne({
    parent_id: parentId,
    ...(childId ? { child_id: childId } : {}),
    is_active: true,
  }).sort({ created_at: -1 }).lean();

  if (existing) return existing;

  let title = 'General Support';
  if (childId) {
    const child = await ChildModel.findById(childId).lean();
    title = child ? `Support for ${child.name}` : 'Child Support';
  }
  const created = await ChatThreadModel.create({
    parent_id: parentId,
    child_id:  childId,
    title,
  });
  return created.toObject();
}

export async function getThreadHistory(threadId: string, user: AuthPayload) {
  const thread = await ChatThreadModel.findById(threadId).lean();
  if (!thread) throw new AppError('NOT_FOUND', 'Thread not found');
  if (thread.parent_id !== user.sub && user.role !== 'center_head') {
    throw new AppError('FORBIDDEN', 'Access denied');
  }
  return ChatMessageModel.find({ thread_id: threadId })
    .sort({ created_at: 1 })
    .lean();
}

export async function sendMessage(threadId: string, userMessage: string, user: AuthPayload) {
  const thread = await ChatThreadModel.findById(threadId).lean();
  if (!thread) throw new AppError('NOT_FOUND', 'Thread not found');
  if (thread.parent_id !== user.sub && user.role !== 'center_head') {
    throw new AppError('FORBIDDEN', 'Access denied');
  }

  // Save user message
  await ChatMessageModel.create({
    thread_id: threadId,
    role:      'user',
    content:   userMessage,
  });

  // Build conversation context (last 10 messages)
  const history = await ChatMessageModel.find({ thread_id: threadId })
    .sort({ created_at: -1 }).limit(10).lean();
  history.reverse();

  const contextLines = history
    .slice(0, -1) // exclude the message we just saved
    .map((m) => `${m.role === 'user' ? 'Parent' : 'NaiviSense AI'}: ${m.content}`)
    .join('\n');

  const prompt = `${SYSTEM_PROMPT}

${contextLines ? `Conversation so far:\n${contextLines}\n` : ''}
Parent: ${userMessage}
NaiviSense AI:`;

  const { text, inputTokens, outputTokens } = await generateText(prompt);

  const assistantMsg = await ChatMessageModel.create({
    thread_id:     threadId,
    role:          'assistant',
    content:       text,
    input_tokens:  inputTokens,
    output_tokens: outputTokens,
  });

  return assistantMsg;
}

export async function listThreads(user: AuthPayload) {
  if (!['parent', 'center_head'].includes(user.role)) {
    throw new AppError('FORBIDDEN', 'Access denied');
  }
  const filter = user.role === 'center_head' ? {} : { parent_id: user.sub };
  return ChatThreadModel.find(filter).sort({ updated_at: -1 }).limit(20).lean();
}

export async function closeThread(threadId: string, user: AuthPayload) {
  const thread = await ChatThreadModel.findById(threadId).lean();
  if (!thread) throw new AppError('NOT_FOUND', 'Thread not found');
  if (thread.parent_id !== user.sub && user.role !== 'center_head') {
    throw new AppError('FORBIDDEN', 'Access denied');
  }
  await ChatThreadModel.findByIdAndUpdate(threadId, { is_active: false });
}

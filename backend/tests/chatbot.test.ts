import { describe, it, expect, vi, beforeEach } from 'vitest';
import request from 'supertest';
import app from '../src/app';
import './setup';

vi.mock('../src/jobs/queues', () => ({
  snapshotQueue: { add: vi.fn().mockResolvedValue(undefined) },
  chunkQueue:    { add: vi.fn().mockResolvedValue(undefined) },
  embedQueue:    { add: vi.fn().mockResolvedValue(undefined) },
  reportQueue:   { add: vi.fn().mockResolvedValue(undefined) },
}));

vi.mock('../src/config/gemini', () => ({
  GEMINI_MODEL: 'gemini-1.5-flash',
  generateText: vi.fn().mockResolvedValue({
    text:         'This is an AI response.',
    inputTokens:  10,
    outputTokens: 20,
  }),
}));

const auth   = '/api/v1/auth';
const chatbot = '/api/v1/chatbot';

async function registerAndLogin(phone: string, role = 'parent') {
  await request(app).post(`${auth}/register`).send({
    name: 'Test User', phone, password: 'pass1234', role,
  });
  const res = await request(app).post(`${auth}/login`).send({ phone, password: 'pass1234' });
  return res.body.accessToken as string;
}

describe('POST /api/v1/chatbot/thread', () => {
  it('creates or returns a thread for a parent', async () => {
    const token = await registerAndLogin('+910000000100');
    const res = await request(app)
      .post(`${chatbot}/thread`)
      .set('Authorization', `Bearer ${token}`)
      .send({});
    expect(res.status).toBe(200);
    expect(res.body._id).toBeDefined();
    expect(res.body.is_active).toBe(true);
  });

  it('returns same thread on second call (idempotent)', async () => {
    const token = await registerAndLogin('+910000000101');
    const res1 = await request(app)
      .post(`${chatbot}/thread`)
      .set('Authorization', `Bearer ${token}`)
      .send({});
    const res2 = await request(app)
      .post(`${chatbot}/thread`)
      .set('Authorization', `Bearer ${token}`)
      .send({});
    expect(res1.body._id).toBe(res2.body._id);
  });

  it('rejects non-parent/center_head roles', async () => {
    const token = await registerAndLogin('+910000000102', 'therapist');
    const res = await request(app)
      .post(`${chatbot}/thread`)
      .set('Authorization', `Bearer ${token}`)
      .send({});
    expect(res.status).toBe(403);
  });
});

describe('POST /api/v1/chatbot/thread/:id/message', () => {
  it('sends a message and returns AI reply', async () => {
    const token = await registerAndLogin('+910000000103');
    const threadRes = await request(app)
      .post(`${chatbot}/thread`)
      .set('Authorization', `Bearer ${token}`)
      .send({});
    const threadId = threadRes.body._id;

    const res = await request(app)
      .post(`${chatbot}/thread/${threadId}/messages`)
      .set('Authorization', `Bearer ${token}`)
      .send({ message: 'Hello, how can I help my child?' });

    expect(res.status).toBe(200);
    expect(res.body.role).toBe('assistant');
    expect(res.body.content).toBe('This is an AI response.');
  });
});

describe('GET /api/v1/chatbot', () => {
  it('lists threads for the authenticated parent', async () => {
    const token = await registerAndLogin('+910000000104');
    await request(app)
      .post(`${chatbot}/thread`)
      .set('Authorization', `Bearer ${token}`)
      .send({});

    const res = await request(app)
      .get(chatbot)
      .set('Authorization', `Bearer ${token}`);
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
    expect(res.body.length).toBeGreaterThan(0);
  });
});

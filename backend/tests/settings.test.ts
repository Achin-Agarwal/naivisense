import { describe, it, expect, vi } from 'vitest';
import request from 'supertest';
import app from '../src/app';
import './setup';

vi.mock('../src/jobs/queues', () => ({
  snapshotQueue: { add: vi.fn().mockResolvedValue(undefined) },
  chunkQueue:    { add: vi.fn().mockResolvedValue(undefined) },
  embedQueue:    { add: vi.fn().mockResolvedValue(undefined) },
  reportQueue:   { add: vi.fn().mockResolvedValue(undefined) },
}));

const auth     = '/api/v1/auth';
const settings = '/api/v1/settings';

async function loginAs(phone: string, role: string) {
  await request(app).post(`${auth}/register`).send({
    name: 'Test', phone, password: 'pass1234', role,
  });
  const res = await request(app).post(`${auth}/login`).send({ phone, password: 'pass1234' });
  return res.body.accessToken as string;
}

describe('PUT /api/v1/settings/:key', () => {
  it('center_head can upsert a setting', async () => {
    const token = await loginAs('+912000000300', 'center_head');
    const res = await request(app)
      .put(`${settings}/session_fee_default`)
      .set('Authorization', `Bearer ${token}`)
      .send({ value: 500 });
    expect(res.status).toBe(200);
    expect(res.body.key).toBe('session_fee_default');
    expect(res.body.value).toBe(500);
  });

  it('non-center_head is rejected with 403', async () => {
    const token = await loginAs('+912000000301', 'therapist');
    const res = await request(app)
      .put(`${settings}/some_key`)
      .set('Authorization', `Bearer ${token}`)
      .send({ value: 'x' });
    expect(res.status).toBe(403);
  });
});

describe('GET /api/v1/settings', () => {
  it('center_head can list all settings', async () => {
    const token = await loginAs('+912000000310', 'center_head');
    await request(app).put(`${settings}/max_sessions`).set('Authorization', `Bearer ${token}`).send({ value: 10 });
    await request(app).put(`${settings}/welcome_msg`).set('Authorization', `Bearer ${token}`).send({ value: 'Hello' });

    const res = await request(app).get(settings).set('Authorization', `Bearer ${token}`);
    expect(res.status).toBe(200);
    expect(res.body.length).toBeGreaterThanOrEqual(2);
  });
});

describe('GET /api/v1/settings/:key', () => {
  it('retrieves a single setting by key', async () => {
    const token = await loginAs('+912000000320', 'center_head');
    await request(app).put(`${settings}/center_name`).set('Authorization', `Bearer ${token}`).send({ value: 'NaiviSense' });

    const res = await request(app).get(`${settings}/center_name`).set('Authorization', `Bearer ${token}`);
    expect(res.status).toBe(200);
    expect(res.body.value).toBe('NaiviSense');
  });

  it('returns 404 for missing key', async () => {
    const token = await loginAs('+912000000321', 'center_head');
    const res = await request(app).get(`${settings}/nonexistent_key`).set('Authorization', `Bearer ${token}`);
    expect(res.status).toBe(404);
  });
});

describe('DELETE /api/v1/settings/:key', () => {
  it('center_head can delete a setting', async () => {
    const token = await loginAs('+912000000330', 'center_head');
    await request(app).put(`${settings}/temp_key`).set('Authorization', `Bearer ${token}`).send({ value: 'temp' });

    const res = await request(app).delete(`${settings}/temp_key`).set('Authorization', `Bearer ${token}`);
    expect(res.status).toBe(200);

    const check = await request(app).get(`${settings}/temp_key`).set('Authorization', `Bearer ${token}`);
    expect(check.status).toBe(404);
  });
});

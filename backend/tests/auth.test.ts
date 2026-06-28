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

const base = '/api/v1/auth';

describe('POST /api/v1/auth/register', () => {
  it('creates a user and returns tokens without password_hash', async () => {
    const res = await request(app).post(`${base}/register`).send({
      name: 'Dr. Sharma', phone: '+919876543210', password: 'secret123', role: 'therapist',
    });
    expect(res.status).toBe(201);
    expect(res.body.accessToken).toBeDefined();
    expect(res.body.refreshToken).toBeDefined();
    expect(res.body.user.password_hash).toBeUndefined();
  });

  it('rejects duplicate phone with 409 CONFLICT', async () => {
    const data = { name: 'Test', phone: '+919876543211', password: 'abc12345', role: 'parent' };
    await request(app).post(`${base}/register`).send(data);
    const res = await request(app).post(`${base}/register`).send(data);
    expect(res.status).toBe(409);
    expect(res.body.error.code).toBe('CONFLICT');
  });

  it('rejects invalid phone format', async () => {
    const res = await request(app).post(`${base}/register`).send({
      name: 'Test', phone: 'not-a-phone', password: 'abc12345', role: 'parent',
    });
    expect(res.status).toBe(400);
    expect(res.body.error.code).toBe('INVALID_INPUT');
  });
});

describe('POST /api/v1/auth/login', () => {
  it('logs in with correct credentials and returns tokens', async () => {
    await request(app).post(`${base}/register`).send({
      name: 'Parent A', phone: '+919000000001', password: 'mypassword', role: 'parent',
    });
    const res = await request(app).post(`${base}/login`).send({
      phone: '+919000000001', password: 'mypassword',
    });
    expect(res.status).toBe(200);
    expect(res.body.accessToken).toBeDefined();
    expect(res.body.user.password_hash).toBeUndefined();
  });

  it('rejects wrong password with 401', async () => {
    const res = await request(app).post(`${base}/login`).send({
      phone: '+919000000001', password: 'wrongpass',
    });
    expect(res.status).toBe(401);
    expect(res.body.error.code).toBe('UNAUTHORIZED');
  });
});

describe('Protected route', () => {
  it('returns 401 without token', async () => {
    const res = await request(app).get('/api/v1/users/me');
    expect(res.status).toBe(401);
  });

  it('returns 200 with valid token', async () => {
    const reg = await request(app).post(`${base}/register`).send({
      name: 'Center Head', phone: '+919111111111', password: 'pass1234', role: 'center_head',
    });
    const res = await request(app)
      .get('/api/v1/users/me')
      .set('Authorization', `Bearer ${reg.body.accessToken}`);
    expect(res.status).toBe(200);
    expect(res.body.role).toBe('center_head');
  });
});

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
const payments = '/api/v1/payments';

async function registerAndLogin(phone: string, role = 'parent') {
  await request(app).post(`${auth}/register`).send({
    name: 'Test', phone, password: 'pass1234', role,
  });
  const res = await request(app).post(`${auth}/login`).send({ phone, password: 'pass1234' });
  return { token: res.body.accessToken as string, userId: res.body.user._id as string };
}

describe('POST /api/v1/payments', () => {
  it('center_head can create a payment', async () => {
    const { token: chToken } = await registerAndLogin('+911000000200', 'center_head');
    const { userId: parentId } = await registerAndLogin('+911000000201', 'parent');

    const res = await request(app)
      .post(payments)
      .set('Authorization', `Bearer ${chToken}`)
      .send({
        parent_id:   parentId,
        type:        'session_fee',
        amount_paise: 50000,
        notes:       'April session fee',
      });
    expect(res.status).toBe(201);
    expect(res.body.amount_paise).toBe(50000);
    expect(res.body.status).toBe('pending');
  });

  it('parent cannot create a payment', async () => {
    const { token } = await registerAndLogin('+911000000202', 'parent');
    const res = await request(app)
      .post(payments)
      .set('Authorization', `Bearer ${token}`)
      .send({ type: 'session_fee', amount_paise: 10000 });
    expect(res.status).toBe(403);
  });
});

describe('GET /api/v1/payments', () => {
  it('parent sees only their own payments', async () => {
    const { token: chToken } = await registerAndLogin('+911000000210', 'center_head');
    const { token: pToken, userId: parentId } = await registerAndLogin('+911000000211', 'parent');
    const { userId: otherParentId } = await registerAndLogin('+911000000212', 'parent');

    await request(app).post(payments).set('Authorization', `Bearer ${chToken}`)
      .send({ parent_id: parentId, type: 'session_fee', amount_paise: 10000 });
    await request(app).post(payments).set('Authorization', `Bearer ${chToken}`)
      .send({ parent_id: otherParentId, type: 'session_fee', amount_paise: 20000 });

    const res = await request(app).get(payments).set('Authorization', `Bearer ${pToken}`);
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
    res.body.forEach((p: any) => expect(p.parent_id).toBe(parentId));
  });

  it('center_head sees all payments', async () => {
    const { token: chToken } = await registerAndLogin('+911000000220', 'center_head');
    const { userId: parentId } = await registerAndLogin('+911000000221', 'parent');

    await request(app).post(payments).set('Authorization', `Bearer ${chToken}`)
      .send({ parent_id: parentId, type: 'session_fee', amount_paise: 30000 });

    const res = await request(app).get(payments).set('Authorization', `Bearer ${chToken}`);
    expect(res.status).toBe(200);
    expect(res.body.length).toBeGreaterThan(0);
  });
});

describe('PATCH /api/v1/payments/:id/status', () => {
  it('center_head can mark a payment as paid', async () => {
    const { token: chToken } = await registerAndLogin('+911000000230', 'center_head');
    const { userId: parentId } = await registerAndLogin('+911000000231', 'parent');

    const created = await request(app).post(payments).set('Authorization', `Bearer ${chToken}`)
      .send({ parent_id: parentId, type: 'session_fee', amount_paise: 15000 });
    const id = created.body._id;

    const res = await request(app)
      .patch(`${payments}/${id}/status`)
      .set('Authorization', `Bearer ${chToken}`)
      .send({ status: 'paid' });
    expect(res.status).toBe(200);
    expect(res.body.status).toBe('paid');
  });
});

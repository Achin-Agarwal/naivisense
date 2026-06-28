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

const base     = '/api/v1';
const authBase = `${base}/auth`;

async function reg(phone: string, role: 'center_head' | 'therapist' | 'parent') {
  const res = await request(app).post(`${authBase}/register`).send({
    name: `User ${phone}`, phone, password: 'pass1234', role,
  });
  return { token: res.body.accessToken, userId: res.body.user._id as string };
}

describe('POST /api/v1/sessions', () => {
  it('therapist can create a session', async () => {
    const { token: chToken }   = await reg('+919100000001', 'center_head');
    const { token: tToken, userId: tId } = await reg('+919100000002', 'therapist');
    const { userId: parentId } = await reg('+919100000003', 'parent');

    const childRes = await request(app)
      .post(`${base}/children`)
      .set('Authorization', `Bearer ${chToken}`)
      .send({
        name: 'Raj', dob: '2018-06-01T00:00:00Z', gender: 'boy',
        diagnosis: ['autism'], severity: 'mild', therapy_targets: ['speech'],
        parent_id: parentId, therapist_id: tId,
        consent_record: { given_at: new Date().toISOString(), given_by: 'Parent' },
      });

    const sessionRes = await request(app)
      .post(`${base}/sessions`)
      .set('Authorization', `Bearer ${tToken}`)
      .send({
        child_id:     childRes.body._id,
        scheduled_at: new Date(Date.now() + 86400000).toISOString(),
        type:         'speech',
        mode:         'offline',
      });

    expect(sessionRes.status).toBe(201);
    expect(sessionRes.body.status).toBe('scheduled');
  });

  it('online sessions store a meeting link and calendar event id', async () => {
    const { token: chToken }   = await reg('+919100000010', 'center_head');
    const { token: tToken, userId: tId } = await reg('+919100000011', 'therapist');
    const { userId: parentId } = await reg('+919100000012', 'parent');

    const childRes = await request(app)
      .post(`${base}/children`)
      .set('Authorization', `Bearer ${chToken}`)
      .send({
        name: 'Kabir', dob: '2018-06-01T00:00:00Z', gender: 'boy',
        diagnosis: ['autism'], severity: 'mild', therapy_targets: ['speech'],
        parent_id: parentId,
        parent_email: 'parent@example.com',
        enrollment_mode: 'online',
        therapists: [{ therapist_id: tId, therapy_type: 'speech' }],
        consent_record: { given_at: new Date().toISOString(), given_by: 'Parent' },
      });

    const sessionRes = await request(app)
      .post(`${base}/sessions`)
      .set('Authorization', `Bearer ${tToken}`)
      .send({
        child_id:     childRes.body._id,
        scheduled_at: new Date(Date.now() + 86400000).toISOString(),
        type:         'speech',
        mode:         'online',
      });

    expect(sessionRes.status).toBe(201);
    expect(sessionRes.body.meeting_link).toContain(sessionRes.body._id);
    expect(sessionRes.body.calendar_event_id).toContain(sessionRes.body._id);
    expect(sessionRes.body.calendar_provider).toBe('manual');
  });

  it('parent cannot create a session — 403', async () => {
    const { token: pToken }    = await reg('+919100000004', 'parent');
    const { userId: parentId } = await reg('+919100000005', 'parent');
    const { token: chToken }   = await reg('+919100000006', 'center_head');

    const childRes = await request(app)
      .post(`${base}/children`)
      .set('Authorization', `Bearer ${chToken}`)
      .send({
        name: 'Priya', dob: '2019-01-01T00:00:00Z', gender: 'girl',
        diagnosis: ['adhd'], severity: 'moderate', therapy_targets: ['ot'],
        parent_id: parentId,
        consent_record: { given_at: new Date().toISOString(), given_by: 'Parent' },
      });

    const res = await request(app)
      .post(`${base}/sessions`)
      .set('Authorization', `Bearer ${pToken}`)
      .send({
        child_id:     childRes.body._id,
        scheduled_at: new Date(Date.now() + 86400000).toISOString(),
        type:         'ot',
      });
    expect(res.status).toBe(403);
  });

  it('therapist can submit notes and session becomes completed', async () => {
    const { token: chToken }   = await reg('+919100000007', 'center_head');
    const { token: tToken, userId: tId } = await reg('+919100000008', 'therapist');
    const { userId: parentId } = await reg('+919100000009', 'parent');

    const childRes = await request(app)
      .post(`${base}/children`)
      .set('Authorization', `Bearer ${chToken}`)
      .send({
        name: 'Ananya', dob: '2017-03-01T00:00:00Z', gender: 'girl',
        diagnosis: ['autism'], severity: 'severe', therapy_targets: ['speech', 'ot'],
        parent_id: parentId, therapist_id: tId,
        consent_record: { given_at: new Date().toISOString(), given_by: 'Mother' },
      });

    const sessionRes = await request(app)
      .post(`${base}/sessions`)
      .set('Authorization', `Bearer ${tToken}`)
      .send({
        child_id:     childRes.body._id,
        scheduled_at: new Date(Date.now() + 86400000).toISOString(),
        type:         'speech',
      });

    const notesRes = await request(app)
      .post(`${base}/sessions/${sessionRes.body._id}/notes`)
      .set('Authorization', `Bearer ${tToken}`)
      .send({
        mood:                'happy',
        attention_score:     7,
        communication_score: 8,
        motor_score:         6,
        behavior_score:      7,
        activities:          ['word matching', 'picture naming'],
        notes:               'Good session, child responded well.',
      });

    expect(notesRes.status).toBe(200);
    expect(notesRes.body.status).toBe('completed');
    expect(notesRes.body.notes.mood).toBe('happy');
  });
});

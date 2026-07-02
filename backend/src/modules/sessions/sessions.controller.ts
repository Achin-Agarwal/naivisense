import * as SessionService  from './sessions.service';
import { CreateSessionSchema, SubmitNotesSchema, UpdateSessionSchema } from './sessions.schema';
import { AppError }          from '../../middleware/error';
import { asyncHandler }      from '../../utils/http';

export const create = asyncHandler(async (req, res) => {
  const input   = CreateSessionSchema.parse(req.body);
  const session = await SessionService.createSession(input, req.user!);
  res.status(201).json(session);
});

export const update = asyncHandler(async (req, res) => {

  const input = UpdateSessionSchema.parse(req.body);

  const session = await SessionService.updateSession(
    req.params.id,
    input,
    req.user!
  );

  res.json(session);

});

export const cancel = asyncHandler(async (req, res) => {

  const session =
    await SessionService.cancelSession(
      req.params.id,
      req.user!
    );

  res.json(session);

});

export const submitNotes = asyncHandler(async (req, res) => {
  const notes   = SubmitNotesSchema.parse(req.body);
  const session = await SessionService.submitNotes(req.params.id, notes, req.user!);
  res.json(session);
});

export const upcoming = asyncHandler(async (req, res) => {
  const sessions = await SessionService.getUpcomingSessions(req.user!);
  res.json(sessions);
});

export const list = asyncHandler(async (req, res) => {
  const { childId } = req.query;
  if (!childId || typeof childId !== 'string') {
    throw new AppError('INVALID_INPUT', 'childId query param is required');
  }
  const sessions = await SessionService.listSessions(childId, req.user!);
  res.json(sessions);
});

export const nextSession = asyncHandler(async (req, res) => {
  const { childId } = req.query;
  if (!childId || typeof childId !== 'string') {
    throw new AppError('INVALID_INPUT', 'childId query param is required');
  }
  const session = await SessionService.getNextSession(childId, req.user!);
  res.json(session);
});

import * as AttendanceService from './attendance.service';
import { MarkAttendanceSchema, SyncMeetAttendanceSchema } from './attendance.schema';
import { AppError }     from '../../middleware/error';
import { asyncHandler } from '../../utils/http';

export const mark = asyncHandler(async (req, res) => {
  const input      = MarkAttendanceSchema.parse(req.body);
  const attendance = await AttendanceService.markAttendance(input, req.user!);
  res.status(201).json(attendance);
});

export const syncMeet = asyncHandler(async (req, res) => {
  const input      = SyncMeetAttendanceSchema.parse(req.body);
  const attendance = await AttendanceService.syncMeetAttendance(input, req.user!);
  res.status(201).json(attendance);
});

export const list = asyncHandler(async (req, res) => {
  const { childId } = req.query;
  if (!childId || typeof childId !== 'string') {
    throw new AppError('INVALID_INPUT', 'childId query param is required');
  }
  const records = await AttendanceService.listAttendance(childId, req.user!);
  res.json(records);
});

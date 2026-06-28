import { z } from 'zod';

export const MarkAttendanceSchema = z.object({
  child_id:   z.string().length(24),
  session_id: z.string().length(24).optional(),
  date:       z.string().datetime({ offset: true }),
  status:     z.enum(['present', 'absent', 'late']),
  source:     z.enum(['manual', 'google_meet', 'geo']).optional(),
  location:   z.object({
    lat:     z.number(),
    lng:     z.number(),
    address: z.string().optional(),
  }).optional(),
  notes:      z.string().max(500).optional(),
});

export const SyncMeetAttendanceSchema = z.object({
  session_id: z.string().length(24),
});

export type MarkAttendanceInput = z.infer<typeof MarkAttendanceSchema>;
export type SyncMeetAttendanceInput = z.infer<typeof SyncMeetAttendanceSchema>;

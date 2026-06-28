import mongoose, { Schema, Document } from 'mongoose';

export interface IAttendance extends Document {
  child_id:   mongoose.Types.ObjectId;
  session_id: mongoose.Types.ObjectId | null;
  date:       Date;
  status:     'present' | 'absent' | 'late';
  marked_by:  mongoose.Types.ObjectId;
  source?:    'manual' | 'google_meet' | 'geo';
  location?:  { lat: number; lng: number; address?: string };
  notes?:     string;
}

const attendanceSchema = new Schema<IAttendance>(
  {
    child_id:   { type: Schema.Types.ObjectId, ref: 'Child',   required: true },
    session_id: { type: Schema.Types.ObjectId, ref: 'Session', default: null },
    date:       { type: Date, required: true },
    status:     { type: String, enum: ['present', 'absent', 'late'], required: true },
    marked_by:  { type: Schema.Types.ObjectId, ref: 'User', required: true },
    source:     { type: String, enum: ['manual', 'google_meet', 'geo'], default: 'manual' },
    location: {
      lat:     { type: Number },
      lng:     { type: Number },
      address: { type: String },
    },
    notes:      { type: String },
  },
  { timestamps: true },
);

attendanceSchema.index({ child_id: 1, date: -1 });

export const AttendanceModel = mongoose.model<IAttendance>('Attendance', attendanceSchema);

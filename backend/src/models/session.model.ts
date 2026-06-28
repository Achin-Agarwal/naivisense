import mongoose, { Schema, Document } from 'mongoose';

export interface ISessionNotes {
  mood:                string;
  attention_score:     number;
  communication_score: number;
  motor_score:         number;
  behavior_score:      number;
  activities:          string[];
  what_worked?:        string;
  what_didnt_work?:    string;
  homework?:           string;
  notes?:              string;
  // Extended therapist observation fields
  observations?:       string;
  progress_log?:       string;
  tantrums_observed?:  string;
  resolution_notes?:   string;
  follow_up_required:  boolean;
  submitted_at:        Date;
}

export interface ISession extends Document {
  child_id:           mongoose.Types.ObjectId;
  therapist_id:       mongoose.Types.ObjectId;
  scheduled_at:       Date;
  type:               'speech' | 'ot' | 'behavior' | 'special_ed';
  mode:               'online' | 'offline';
  duration_min:       number;
  status:             'scheduled' | 'completed' | 'cancelled';
  meeting_link?:      string;
  calendar_event_id?: string;
  calendar_provider?: 'google' | 'manual';
  calendar_synced_at?: Date;
  attendance_source?: 'google_meet' | 'manual' | 'geo';
  offline_location?:  string;
  notes?:             ISessionNotes;
}

const sessionNotesSchema = new Schema<ISessionNotes>(
  {
    mood:                { type: String, enum: ['sad', 'calm', 'happy', 'excited'] },
    attention_score:     { type: Number, min: 1, max: 10 },
    communication_score: { type: Number, min: 1, max: 10 },
    motor_score:         { type: Number, min: 1, max: 10 },
    behavior_score:      { type: Number, min: 1, max: 10 },
    activities:          [{ type: String }],
    what_worked:         { type: String },
    what_didnt_work:     { type: String },
    homework:            { type: String },
    notes:               { type: String },
    observations:        { type: String },
    progress_log:        { type: String },
    tantrums_observed:   { type: String },
    resolution_notes:    { type: String },
    follow_up_required:  { type: Boolean, default: false },
    submitted_at:        { type: Date, default: Date.now },
  },
  { _id: false },
);

const sessionSchema = new Schema<ISession>(
  {
    child_id:     { type: Schema.Types.ObjectId, ref: 'Child', required: true },
    therapist_id: { type: Schema.Types.ObjectId, ref: 'User',  required: true },
    scheduled_at: { type: Date, required: true },
    type:         { type: String, enum: ['speech', 'ot', 'behavior', 'special_ed'], required: true },
    mode:         { type: String, enum: ['online', 'offline'], default: 'offline' },
    duration_min: { type: Number, default: 45 },
    status:       { type: String, enum: ['scheduled', 'completed', 'cancelled'], default: 'scheduled' },
    meeting_link:       { type: String },
    calendar_event_id:  { type: String },
    calendar_provider:  { type: String, enum: ['google', 'manual'] },
    calendar_synced_at: { type: Date },
    attendance_source:  { type: String, enum: ['google_meet', 'manual', 'geo'] },
    offline_location:   { type: String },
    notes:              { type: sessionNotesSchema },
  },
  { timestamps: true },
);

sessionSchema.index({ therapist_id: 1, scheduled_at: -1 });
sessionSchema.index({ child_id:     1, scheduled_at: -1 });

export const SessionModel = mongoose.model<ISession>('Session', sessionSchema);

import mongoose, { Schema, Document } from 'mongoose';

export type AlertCategory = 'tantrum' | 'behavior' | 'health' | 'regression' | 'activity' | 'video_review' | 'other';
export type AlertSource   = 'parent' | 'therapist' | 'clinical_psychologist';

export interface IAlert extends Document {
  child_id:             mongoose.Types.ObjectId;
  raised_by:            mongoose.Types.ObjectId;
  type:                 'fever' | 'regression' | 'aggression' | 'seizure' | 'sleep_issue' | 'injury' | 'emotional_stress' | 'other';
  description:          string;
  severity:             'low' | 'medium' | 'high';
  priority:             'normal' | 'high';
  category:             AlertCategory;
  source:               AlertSource;
  status:               'open' | 'seen' | 'resolved';
  resolved_by?:         mongoose.Types.ObjectId;
  resolution_note?:     string;
  linked_video_id?:     mongoose.Types.ObjectId;
  weekly_tracking_date?: Date;
  created_at:           Date;
  acknowledged_at:      Date | null;
  resolved_at:          Date | null;
}

const alertSchema = new Schema<IAlert>(
  {
    child_id:             { type: Schema.Types.ObjectId, ref: 'Child', required: true },
    raised_by:            { type: Schema.Types.ObjectId, ref: 'User',  required: true },
    type:                 {
      type:     String,
      enum:     ['fever', 'regression', 'aggression', 'seizure', 'sleep_issue', 'injury', 'emotional_stress', 'other'],
      required: true,
    },
    description:          { type: String, required: true },
    severity:             { type: String, enum: ['low', 'medium', 'high'], required: true },
    priority:             { type: String, enum: ['normal', 'high'], default: 'normal' },
    category:             { type: String, enum: ['tantrum', 'behavior', 'health', 'regression', 'activity', 'video_review', 'other'], default: 'other' },
    source:               { type: String, enum: ['parent', 'therapist', 'clinical_psychologist'], required: true },
    status:               { type: String, enum: ['open', 'seen', 'resolved'], default: 'open' },
    resolved_by:          { type: Schema.Types.ObjectId, ref: 'User' },
    resolution_note:      { type: String },
    linked_video_id:      { type: Schema.Types.ObjectId, ref: 'Video' },
    weekly_tracking_date: { type: Date },
    acknowledged_at:      { type: Date, default: null },
    resolved_at:          { type: Date, default: null },
  },
  { timestamps: { createdAt: 'created_at', updatedAt: false } },
);

alertSchema.index({ child_id: 1, status: 1 });
alertSchema.index({ child_id: 1, priority: 1 });

export const AlertModel = mongoose.model<IAlert>('Alert', alertSchema);

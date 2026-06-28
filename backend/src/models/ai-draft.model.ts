import mongoose, { Schema, Document } from 'mongoose';

export type AiDraftType = 'therapy_plan' | 'home_plan' | 'diet_summary' | 'reinforcement_activities' | 'insights';
export type AiDraftStatus = 'pending' | 'approved' | 'rejected';

export interface IAiDraft extends Document {
  child_id:     mongoose.Types.ObjectId;
  generated_by: mongoose.Types.ObjectId;
  type:         AiDraftType;
  status:       AiDraftStatus;
  content:      string;
  model_used:   string;
  prompt_hash?: string;
  approved_by?: mongoose.Types.ObjectId;
  approved_at?: Date;
  created_at:   Date;
  updated_at:   Date;
}

const aiDraftSchema = new Schema<IAiDraft>(
  {
    child_id:     { type: Schema.Types.ObjectId, ref: 'Child', required: true },
    generated_by: { type: Schema.Types.ObjectId, ref: 'User',  required: true },
    type:         { type: String, enum: ['therapy_plan', 'home_plan', 'diet_summary', 'reinforcement_activities', 'insights'], required: true },
    status:       { type: String, enum: ['pending', 'approved', 'rejected'], default: 'pending' },
    content:      { type: String, required: true },
    model_used:   { type: String, default: 'gemini-1.5-flash' },
    prompt_hash:  { type: String },
    approved_by:  { type: Schema.Types.ObjectId, ref: 'User' },
    approved_at:  { type: Date },
  },
  { timestamps: { createdAt: 'created_at', updatedAt: 'updated_at' } },
);

aiDraftSchema.index({ child_id: 1, type: 1, status: 1 });
aiDraftSchema.index({ generated_by: 1 });

export const AiDraftModel = mongoose.model<IAiDraft>('AiDraft', aiDraftSchema);

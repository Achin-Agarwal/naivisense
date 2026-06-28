import mongoose, { Schema, Document } from 'mongoose';

export type GoalStatus = 'proposed' | 'accepted' | 'active' | 'completed' | 'paused';

export interface IGoal extends Document {
  child_id:     mongoose.Types.ObjectId;
  created_by:   mongoose.Types.ObjectId;
  title:        string;
  description?: string;
  priority:     number;
  status:       GoalStatus;
  accepted_by?: mongoose.Types.ObjectId;
  accepted_at?: Date;
  target_date?: Date;
  created_at:   Date;
  updated_at:   Date;
}

const goalSchema = new Schema<IGoal>(
  {
    child_id:    { type: Schema.Types.ObjectId, ref: 'Child', required: true },
    created_by:  { type: Schema.Types.ObjectId, ref: 'User',  required: true },
    title:       { type: String, required: true, trim: true },
    description: { type: String },
    priority:    { type: Number, default: 0 },
    status:      { type: String, enum: ['proposed', 'accepted', 'active', 'completed', 'paused'], default: 'proposed' },
    accepted_by: { type: Schema.Types.ObjectId, ref: 'User' },
    accepted_at: { type: Date },
    target_date: { type: Date },
  },
  { timestamps: { createdAt: 'created_at', updatedAt: 'updated_at' } },
);

goalSchema.index({ child_id: 1, status: 1 });

export const GoalModel = mongoose.model<IGoal>('Goal', goalSchema);

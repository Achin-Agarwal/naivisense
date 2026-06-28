import mongoose, { Schema, Document } from 'mongoose';

export type DietRequestStatus = 'requested' | 'accepted' | 'in_progress' | 'completed' | 'cancelled';

export interface IDietRequest extends Document {
  child_id:             mongoose.Types.ObjectId;
  requested_by:         mongoose.Types.ObjectId;
  requested_by_role:    'therapist' | 'center_head';
  assigned_dietician_id?: mongoose.Types.ObjectId;
  reason:               string;
  status:               DietRequestStatus;
  notes?:               string;
  created_at:           Date;
  updated_at:           Date;
}

const dietRequestSchema = new Schema<IDietRequest>(
  {
    child_id:             { type: Schema.Types.ObjectId, ref: 'Child', required: true },
    requested_by:         { type: Schema.Types.ObjectId, ref: 'User',  required: true },
    requested_by_role:    { type: String, enum: ['therapist', 'center_head'], required: true },
    assigned_dietician_id:{ type: Schema.Types.ObjectId, ref: 'User' },
    reason:               { type: String, required: true },
    status:               { type: String, enum: ['requested', 'accepted', 'in_progress', 'completed', 'cancelled'], default: 'requested' },
    notes:                { type: String },
  },
  { timestamps: { createdAt: 'created_at', updatedAt: 'updated_at' } },
);

dietRequestSchema.index({ child_id: 1, status: 1 });
dietRequestSchema.index({ assigned_dietician_id: 1, status: 1 });

export const DietRequestModel = mongoose.model<IDietRequest>('DietRequest', dietRequestSchema);

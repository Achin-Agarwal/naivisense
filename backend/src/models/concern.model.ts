import mongoose, { Schema, Document } from 'mongoose';

export interface IConcern extends Document {
  child_id:        mongoose.Types.ObjectId;
  created_by:      mongoose.Types.ObjectId;
  created_by_role: 'parent' | 'therapist' | 'clinical_psychologist';
  category:        'tantrum' | 'behavior' | 'health' | 'regression' | 'activity' | 'other';
  description:     string;
  status:          'open' | 'resolved';
  resolved_by?:    mongoose.Types.ObjectId;
  resolution?:     string;
  resolved_at?:    Date;
  created_at:      Date;
  updated_at:      Date;
}

const concernSchema = new Schema<IConcern>(
  {
    child_id:        { type: Schema.Types.ObjectId, ref: 'Child', required: true },
    created_by:      { type: Schema.Types.ObjectId, ref: 'User',  required: true },
    created_by_role: { type: String, enum: ['parent', 'therapist', 'clinical_psychologist'], required: true },
    category:        { type: String, enum: ['tantrum', 'behavior', 'health', 'regression', 'activity', 'other'], required: true },
    description:     { type: String, required: true },
    status:          { type: String, enum: ['open', 'resolved'], default: 'open' },
    resolved_by:     { type: Schema.Types.ObjectId, ref: 'User' },
    resolution:      { type: String },
    resolved_at:     { type: Date },
  },
  { timestamps: { createdAt: 'created_at', updatedAt: 'updated_at' } },
);

concernSchema.index({ child_id: 1, status: 1 });

export const ConcernModel = mongoose.model<IConcern>('Concern', concernSchema);

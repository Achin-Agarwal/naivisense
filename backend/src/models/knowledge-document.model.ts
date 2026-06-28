import mongoose, { Schema, Document } from 'mongoose';

export type KnowledgeDocCategory =
  | 'therapy_protocol'
  | 'diet_guideline'
  | 'assessment_rubric'
  | 'behavior_strategy'
  | 'home_activity'
  | 'general';

export interface IKnowledgeDocument extends Document {
  title:       string;
  category:    KnowledgeDocCategory;
  source:      string;
  content:     string;
  uploaded_by: mongoose.Types.ObjectId;
  is_active:   boolean;
  created_at:  Date;
  updated_at:  Date;
}

const knowledgeDocumentSchema = new Schema<IKnowledgeDocument>(
  {
    title:       { type: String, required: true },
    category:    { type: String, enum: ['therapy_protocol', 'diet_guideline', 'assessment_rubric', 'behavior_strategy', 'home_activity', 'general'], required: true },
    source:      { type: String, default: 'internal' },
    content:     { type: String, required: true },
    uploaded_by: { type: Schema.Types.ObjectId, ref: 'User', required: true },
    is_active:   { type: Boolean, default: true },
  },
  { timestamps: { createdAt: 'created_at', updatedAt: 'updated_at' } },
);

knowledgeDocumentSchema.index({ category: 1, is_active: 1 });

export const KnowledgeDocumentModel = mongoose.model<IKnowledgeDocument>(
  'KnowledgeDocument',
  knowledgeDocumentSchema,
);

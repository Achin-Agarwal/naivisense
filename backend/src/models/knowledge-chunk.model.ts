import mongoose, { Schema, Document } from 'mongoose';

export interface IKnowledgeChunk extends Document {
  document_id: mongoose.Types.ObjectId;
  category:    string;
  chunk_index: number;
  text:        string;
  char_count:  number;
  created_at:  Date;
}

const knowledgeChunkSchema = new Schema<IKnowledgeChunk>(
  {
    document_id: { type: Schema.Types.ObjectId, ref: 'KnowledgeDocument', required: true },
    category:    { type: String, required: true },
    chunk_index: { type: Number, required: true },
    text:        { type: String, required: true },
    char_count:  { type: Number, required: true },
  },
  { timestamps: { createdAt: 'created_at', updatedAt: false } },
);

knowledgeChunkSchema.index({ document_id: 1, chunk_index: 1 });
knowledgeChunkSchema.index({ category: 1 });

export const KnowledgeChunkModel = mongoose.model<IKnowledgeChunk>(
  'KnowledgeChunk',
  knowledgeChunkSchema,
);

import mongoose, { Schema, Document } from 'mongoose';

export type ChatRole = 'user' | 'assistant';

export interface IChatMessage extends Document {
  thread_id:    string;
  role:         ChatRole;
  content:      string;
  input_tokens: number;
  output_tokens: number;
  created_at:   Date;
}

const ChatMessageSchema = new Schema<IChatMessage>({
  thread_id:     { type: String, required: true },
  role:          { type: String, enum: ['user', 'assistant'], required: true },
  content:       { type: String, required: true },
  input_tokens:  { type: Number, default: 0 },
  output_tokens: { type: Number, default: 0 },
}, { timestamps: { createdAt: 'created_at', updatedAt: false } });

ChatMessageSchema.index({ thread_id: 1, created_at: 1 });

export const ChatMessageModel = mongoose.model<IChatMessage>('ChatMessage', ChatMessageSchema);

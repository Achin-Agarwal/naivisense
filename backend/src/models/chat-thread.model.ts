import mongoose, { Schema, Document } from 'mongoose';

export interface IChatThread extends Document {
  parent_id:  string;
  child_id?:  string;
  title?:     string;
  is_active:  boolean;
  created_at: Date;
  updated_at: Date;
}

const ChatThreadSchema = new Schema<IChatThread>({
  parent_id:  { type: String, required: true },
  child_id:   { type: String },
  title:      { type: String },
  is_active:  { type: Boolean, default: true },
}, { timestamps: { createdAt: 'created_at', updatedAt: 'updated_at' } });

ChatThreadSchema.index({ parent_id: 1, created_at: -1 });

export const ChatThreadModel = mongoose.model<IChatThread>('ChatThread', ChatThreadSchema);

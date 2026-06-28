import mongoose, { Schema, Document } from 'mongoose';

export type VideoCategory = 'concern' | 'improvement' | 'session' | 'review' | 'clinical_observation' | 'education';
export type VideoVisibility = 'internal' | 'parent_visible';
export type VideoUploaderRole = 'parent' | 'therapist' | 'clinical_psychologist' | 'center_head';

export interface IVideo extends Document {
  child_id:            mongoose.Types.ObjectId;
  uploaded_by:         mongoose.Types.ObjectId;
  uploaded_by_role:    VideoUploaderRole;
  title:               string;
  description?:        string;
  category:            VideoCategory;
  url:                 string;
  thumbnail_url?:      string;
  cloudinary_public_id: string;
  linked_alert_id?:    mongoose.Types.ObjectId;
  linked_concern_id?:  mongoose.Types.ObjectId;
  linked_review_id?:   mongoose.Types.ObjectId;
  visibility:          VideoVisibility;
  created_at:          Date;
  updated_at:          Date;
}

const videoSchema = new Schema<IVideo>(
  {
    child_id:            { type: Schema.Types.ObjectId, ref: 'Child', required: true },
    uploaded_by:         { type: Schema.Types.ObjectId, ref: 'User',  required: true },
    uploaded_by_role:    { type: String, enum: ['parent', 'therapist', 'clinical_psychologist', 'center_head'], required: true },
    title:               { type: String, required: true },
    description:         { type: String },
    category:            { type: String, enum: ['concern', 'improvement', 'session', 'review', 'clinical_observation', 'education'], required: true },
    url:                 { type: String, required: true },
    thumbnail_url:       { type: String },
    cloudinary_public_id:{ type: String, required: true },
    linked_alert_id:     { type: Schema.Types.ObjectId, ref: 'Alert' },
    linked_concern_id:   { type: Schema.Types.ObjectId, ref: 'Concern' },
    linked_review_id:    { type: Schema.Types.ObjectId, ref: 'Review' },
    visibility:          { type: String, enum: ['internal', 'parent_visible'], default: 'internal' },
  },
  { timestamps: { createdAt: 'created_at', updatedAt: 'updated_at' } },
);

videoSchema.index({ child_id: 1, category: 1 });
videoSchema.index({ child_id: 1, visibility: 1 });

export const VideoModel = mongoose.model<IVideo>('Video', videoSchema);

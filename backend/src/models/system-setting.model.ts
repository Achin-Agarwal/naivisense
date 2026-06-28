import mongoose, { Schema, Document } from 'mongoose';

export interface ISystemSetting extends Document {
  key:        string;
  value:      unknown;
  updated_by: string;
  updated_at: Date;
}

const SystemSettingSchema = new Schema<ISystemSetting>({
  key:        { type: String, required: true, unique: true },
  value:      { type: Schema.Types.Mixed, required: true },
  updated_by: { type: String, required: true },
}, { timestamps: { createdAt: false, updatedAt: 'updated_at' } });

export const SystemSettingModel = mongoose.model<ISystemSetting>('SystemSetting', SystemSettingSchema);

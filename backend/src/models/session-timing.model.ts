import mongoose, { Schema, Document } from 'mongoose';

export interface ISessionTiming extends Document {
  therapist_id: mongoose.Types.ObjectId;
  date: Date;
  start_time: string;
  end_time: string;
  mode: 'online' | 'offline';
  capacity: number;
  booked_count: number;
  is_space_available: boolean;
  created_at: Date;
  updated_at: Date;
}

const sessionTimingSchema = new Schema<ISessionTiming>(
  {
    therapist_id: {
       type: Schema.Types.ObjectId,
        ref: 'User', 
        required: true 
      },
    date: { 
      type: Date, 
      required: true
     },
    start_time: { 
      type: String,
       required: true 
      },
    end_time: { 
      type: String, 
      required: true
     },
    mode: { 
      type: String,
       enum: ['online', 'offline'],
        required: true
       },
    capacity: { 
      type: Number, 
      required: true,
       min: 1
       },
    booked_count: {
       type: Number,
        default: 0, 
        min: 0 
      },
  },
  {
    timestamps: { createdAt: 'created_at', updatedAt: 'updated_at' },
    toJSON: { 
      virtuals: true 
    },
    toObject: {
       virtuals: true
       },
  }
);

sessionTimingSchema.virtual('is_space_available').get(function (this: ISessionTiming) {
  return this.booked_count < this.capacity;
});

sessionTimingSchema.index(
  { therapist_id: 1, date: 1, start_time: 1, end_time: 1 },
  { unique: true }
);

export const SessionTimingModel = mongoose.model<ISessionTiming>('SessionTiming', sessionTimingSchema);
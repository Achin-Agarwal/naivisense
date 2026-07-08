import mongoose, { Schema, Document } from 'mongoose';

export interface IDocument extends Document {
    center_id:      mongoose.Types.ObjectId;
    filename:     string;
    file_size:    number;
    mime_type:    string;
    status:       'PROCESSING' | 'PROCESSED' | 'FAILED';
    chunk_count:  number;
    metadata?:    Record<string, unknown>;
    uploaded_at:  Date;
    processed_at: Date | null;
    updated_at:   Date;
}

const documentSchema = new Schema<IDocument>(
    {
        center_id: {
            type: Schema.Types.ObjectId,
            ref: 'User',
            required: true,
            index: true,
        },

        filename: {
            type: String,
            required: true,
            trim: true,
        },

        file_size: {
            type: Number,
            required: true,
        },

        mime_type: {
            type: String,
            required: true,
        },

        status: {
            type: String,
            enum: ['PROCESSING', 'PROCESSED', 'FAILED'],
            default: 'PROCESSING',
        },

        chunk_count: {
            type: Number,
            default: 0,
        },

        metadata: {
            type: Schema.Types.Mixed,
            default: null,
        },

        processed_at: {
            type: Date,
            default: null,
        },
    },
    {
        timestamps: {
            createdAt: 'uploaded_at',
            updatedAt: 'updated_at',
        },
    },
);

documentSchema.index({ user_id: 1, uploaded_at: -1 });

export const DocumentModel = mongoose.model<IDocument>(
    'Document',
    documentSchema,
);
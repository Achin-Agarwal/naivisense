import mongoose, { Schema, Document } from 'mongoose';

export interface IDocumentChunk extends Document {
    document_id: mongoose.Types.ObjectId;
    center_id:     mongoose.Types.ObjectId;
    content:     string;
    chunk_index: number;
    vector_id:   string;
    metadata?:   Record<string, unknown>;
    created_at:  Date;
}

const documentChunkSchema = new Schema<IDocumentChunk>(
    {
        document_id: {
            type: Schema.Types.ObjectId,
            ref: 'Document',
            required: true,
            index: true,
        },

        center_id: {
            type: Schema.Types.ObjectId,
            ref: 'User',
            required: true,
            index: true,
        },

        content: {
            type: String,
            required: true,
        },

        chunk_index: {
            type: Number,
            required: true,
        },

        vector_id: {
            type: String,
            required: true,
            unique: true,
        },

        metadata: {
            type: Schema.Types.Mixed,
            default: null,
        },
    },
    {
        timestamps: {
            createdAt: 'created_at',
            updatedAt: false,
        },
    },
);

documentChunkSchema.index({
    document_id: 1,
    chunk_index: 1,
});

export const DocumentChunkModel = mongoose.model<IDocumentChunk>(
    'DocumentChunk',
    documentChunkSchema,
);
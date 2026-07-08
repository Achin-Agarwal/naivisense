import mongoose, { Schema, Document } from 'mongoose';

export interface IQueryLog extends Document {
    user_id:             mongoose.Types.ObjectId;
    query:               string;
    response:            string;
    sources:             unknown[];
    confidence:          number;
    latency:             number;
    guardrail_triggered: boolean;
    created_at:          Date;
}

const queryLogSchema = new Schema<IQueryLog>(
    {
        user_id: {
            type: Schema.Types.ObjectId,
            ref: 'User',
            required: true,
            index: true,
        },

        query: {
            type: String,
            required: true,
        },

        response: {
            type: String,
            required: true,
        },

        sources: {
            type: [Schema.Types.Mixed],
            default: [],
        },

        confidence: {
            type: Number,
            required: true,
            min: 0,
            max: 1,
        },

        latency: {
            type: Number,
            required: true,
        },

        guardrail_triggered: {
            type: Boolean,
            default: false,
        },
    },
    {
        timestamps: {
            createdAt: 'created_at',
            updatedAt: false,
        },
    },
);

queryLogSchema.index({
    user_id: 1,
    created_at: -1,
});

export const QueryLogModel = mongoose.model<IQueryLog>(
    'QueryLog',
    queryLogSchema,
);
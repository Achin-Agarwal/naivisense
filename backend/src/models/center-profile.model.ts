import mongoose, { Schema, Document } from "mongoose";

export interface ICenterProfile extends Document {

    user_id: mongoose.Types.ObjectId;

    center_name: string;

    smtp_host: string;

    smtp_port: number;

    smtp_secure: boolean;

    smtp_user: string;

    smtp_password: string; // encrypted

}

const centerProfileSchema = new Schema<ICenterProfile>({

    user_id: {
        type: Schema.Types.ObjectId,
        ref: "User",
        required: true,
        unique: true,
    },

    center_name: {
        type: String,
        required: true,
    },

    smtp_host: {
        type: String,
        default: "",
    },

    smtp_port: {
        type: Number,
        default: 587,
    },

    smtp_secure: {
        type: Boolean,
        default: false,
    },

    smtp_user: {
        type: String,
        default: "",
    },

    smtp_password: {
        type: String,
        default: "",
    },

});

export const CenterProfileModel = mongoose.model<ICenterProfile>(
    "CenterProfile",
    centerProfileSchema
);
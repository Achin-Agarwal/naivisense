import nodemailer from "nodemailer";

import { CenterProfileModel } from "../../models/center-profile.model";

import { decrypt } from "../../utils/crypto";

import { newChildAssignedTemplate } from "./mail.templates";

import { sessionRescheduledParentTemplate } from "./mail.templates";

async function getTransporter(centerHeadId: string) {

    const center = await CenterProfileModel.findOne({

        user_id: centerHeadId

    });

    if (!center)
        throw new Error("Center SMTP not configured");

    const transporter = nodemailer.createTransport({

        host: center.smtp_host,

        port: center.smtp_port,

        secure: center.smtp_secure,

        auth: {

            user: center.smtp_user,

            pass: decrypt(center.smtp_password)

        }

    });

    return {

        transporter,

        sender: center.smtp_user

    };

}

export async function sendNewChildAssignedMail(

    centerHeadId: string,

    therapistEmail: string,

    therapistName: string,

    childName: string,

    therapyType: string

) {

    const { transporter, sender } = await getTransporter(centerHeadId);

    await transporter.sendMail({

        from: sender,

        to: therapistEmail,

        subject: "New Child Assigned",

        html: newChildAssignedTemplate(

            therapistName,

            childName,

            therapyType

        )

    });

}

export async function sendSessionRescheduledMailToParent(
    centerHeadId: string,
    parentEmail: string,
    parentName: string,
    childName: string,
    therapistName: string,
    sessionDate: Date,
    meetingLink?: string
) {

    const { transporter, sender } =
        await getTransporter(centerHeadId);

    await transporter.sendMail({

        from: sender,

        to: parentEmail,

        subject: "Therapy Session Rescheduled",

        html: sessionRescheduledParentTemplate(

            parentName,
            childName,
            sessionDate,
            therapistName,
            meetingLink

        )

    });

}

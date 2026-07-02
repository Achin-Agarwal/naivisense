export function newChildAssignedTemplate(

    therapistName: string,

    childName: string,

    therapyType: string

) {

    return `

        <h2>Hello ${therapistName}</h2>

        <p>

        A new child has been assigned to you.

        </p>

        <table>

            <tr>

                <td>Child</td>

                <td>${childName}</td>

            </tr>

            <tr>

                <td>Therapy</td>

                <td>${therapyType}</td>

            </tr>

        </table>

        <br>

        Please login to NaiviSense for more details.

    `;

}


export function sessionRescheduledParentTemplate(
    parentName: string,
    childName: string,
    sessionDate: Date,
    therapistName: string,
    meetingLink?: string
) {
    return `
        <h2>Hello ${parentName},</h2>

        <p>
            Your child's therapy session has been <b>rescheduled</b>.
        </p>

        <table border="1" cellpadding="8" cellspacing="0">

            <tr>
                <td><b>Child</b></td>
                <td>${childName}</td>
            </tr>

            <tr>
                <td><b>Therapist</b></td>
                <td>${therapistName}</td>
            </tr>

            <tr>
                <td><b>New Session Time</b></td>
                <td>${sessionDate.toLocaleString()}</td>
            </tr>

            ${
                meetingLink
                    ? `
            <tr>
                <td><b>Meeting Link</b></td>
                <td>
                    <a href="${meetingLink}">
                        Join Google Meet
                    </a>
                </td>
            </tr>
            `
                    : ""
            }

        </table>

        <br>

        Please login to NaiviSense if you have any questions.

        <br><br>

        Regards,<br>
        NaiviSense Team
    `;
}
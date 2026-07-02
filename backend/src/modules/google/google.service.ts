import { google } from 'googleapis';
import { AppError } from '../../middleware/error';
import { env }    from '../../config/env';

export interface CalendarEventPayload {
  sessionId:       string;
  scheduledAt:     Date | string;
  durationMin:     number;
  childName:       string;
  parentEmail?:    string;
  therapistEmail?: string;
}

export interface CalendarEventResult {
  calendar_event_id: string;
  meeting_link:      string;
  calendar_provider: 'google' | 'manual';
}

export interface UpdateCalendarEventPayload {
  eventId: string;
  scheduledAt: Date | string;
  durationMin: number;
  childName: string;
  parentEmail?: string;
  therapistEmail?: string;
}

type CalendarClient = ReturnType<typeof google.calendar>;
type MeetClient = ReturnType<typeof google.meet>;

function normalizePrivateKey(key: string): string {
  return key.replace(/\\n/g, '\n');
}

function getGoogleAuth() {
  if (env.GOOGLE_CLIENT_EMAIL && env.GOOGLE_PRIVATE_KEY) {
    return new google.auth.JWT({
      email: env.GOOGLE_CLIENT_EMAIL,
      key: normalizePrivateKey(env.GOOGLE_PRIVATE_KEY),
      scopes: [
        'https://www.googleapis.com/auth/calendar',
        'https://www.googleapis.com/auth/meetings.space.readonly',
      ],
      subject: env.GOOGLE_IMPERSONATE_EMAIL,
    });
  }

  if (env.GOOGLE_CLIENT_ID && env.GOOGLE_CLIENT_SECRET && env.GOOGLE_REFRESH_TOKEN) {
    const auth = new google.auth.OAuth2(env.GOOGLE_CLIENT_ID, env.GOOGLE_CLIENT_SECRET);
    auth.setCredentials({ refresh_token: env.GOOGLE_REFRESH_TOKEN });
    return auth;
  }

  return null;
}

function getCalendarClient(): CalendarClient | null {
  const auth = getGoogleAuth();
  return auth ? google.calendar({ version: 'v3', auth }) : null;
}

function getMeetClient(): MeetClient | null {
  const auth = getGoogleAuth();
  return auth ? google.meet({ version: 'v2', auth }) : null;
}

function fallbackResult(sessionId: string): CalendarEventResult {
  return {
    calendar_event_id: `naivisense-event-${sessionId}`,
    meeting_link:      `https://meet.naivisense.app/session/${sessionId}`,
    calendar_provider: 'manual',
  };
}

function eventMeetingLink(event: {
  hangoutLink?: string | null;
  conferenceData?: { entryPoints?: Array<{ entryPointType?: string | null; uri?: string | null }> } | null;
}): string | undefined {
  return event.hangoutLink ?? event.conferenceData?.entryPoints
    ?.find((entry) => entry.entryPointType === 'video')?.uri ?? undefined;
}

export async function createMeetingLink(sessionId: string): Promise<string> {
  return fallbackResult(sessionId).meeting_link;
}

export async function syncCalendarEvent(payload: CalendarEventPayload): Promise<CalendarEventResult> {
  const calendar = getCalendarClient();
  if (!calendar) return fallbackResult(payload.sessionId);

  const scheduledAt = new Date(payload.scheduledAt);
  const endAt = new Date(scheduledAt.getTime() + payload.durationMin * 60_000);
  const attendees = [payload.parentEmail, payload.therapistEmail]
    .filter((email): email is string => Boolean(email))
    .map((email) => ({ email }));

  const event = await calendar.events.insert({
    calendarId: env.GOOGLE_CALENDAR_ID,
    conferenceDataVersion: 1,
    sendUpdates: attendees.length ? 'all' : 'none',
    requestBody: {
      summary: `Naivisense session - ${payload.childName}`,
      description: 'Therapy session scheduled from Naivisense.',
      start: { dateTime: scheduledAt.toISOString() },
      end:   { dateTime: endAt.toISOString() },
      attendees,
      conferenceData: {
        createRequest: {
          requestId: `naivisense-${payload.sessionId}`,
          conferenceSolutionKey: { type: 'hangoutsMeet' },
        },
      },
    },
  });

  return {
    calendar_event_id: event.data.id ?? `google-event-${payload.sessionId}`,
    meeting_link:      eventMeetingLink(event.data) ?? fallbackResult(payload.sessionId).meeting_link,
    calendar_provider: 'google',
  };
}

export async function fetchMeetAttendance(meetingLink: string, scheduledAt: Date | string) {
  const meet = getMeetClient();
  if (!meet) {
    throw new AppError('SERVICE_UNAVAILABLE', 'Google Meet attendance is not configured');
  }

  const meetingCode = meetingLink
    .split('/')
    .pop()
    ?.replace(/\?.*$/, '')
    .trim();

  if (!meetingCode) {
    throw new AppError('INVALID_INPUT', 'Meeting link does not contain a meeting code');
  }

  const start = new Date(scheduledAt);
  const from = new Date(start.getTime() - 2 * 60 * 60 * 1000).toISOString();
  const to = new Date(start.getTime() + 24 * 60 * 60 * 1000).toISOString();

  const records = await meet.conferenceRecords.list({
    filter: `space.meeting_code = "${meetingCode}" AND start_time >= "${from}" AND start_time <= "${to}"`,
    pageSize: 1,
  });

  const conference = records.data.conferenceRecords?.[0];
  if (!conference?.name) {
    return { participantCount: 0, participantNames: [] as string[] };
  }

  const participants = await meet.conferenceRecords.participants.list({
    parent: conference.name,
    pageSize: 250,
  });

  const participantNames = (participants.data.participants ?? [])
    .map((participant) => participant.signedinUser?.displayName ?? participant.anonymousUser?.displayName)
    .filter((name): name is string => Boolean(name));

  return {
    participantCount: participants.data.participants?.length ?? 0,
    participantNames,
  };
}

export async function updateCalendarEvent(
  payload: UpdateCalendarEventPayload
): Promise<CalendarEventResult> {

  const calendar = getCalendarClient();

  if (!calendar) {
    throw new AppError(
      "SERVICE_UNAVAILABLE",
      "Google Calendar is not configured"
    );
  }

  const scheduledAt = new Date(payload.scheduledAt);

  const endAt = new Date(
    scheduledAt.getTime() +
    payload.durationMin * 60_000
  );

  const attendees = [
    payload.parentEmail,
    payload.therapistEmail,
  ]
    .filter((email): email is string => Boolean(email))
    .map((email) => ({ email }));

  const updatedEvent = await calendar.events.update({

    calendarId: env.GOOGLE_CALENDAR_ID,

    eventId: payload.eventId,

    sendUpdates: "all",

    requestBody: {

      summary: `NaiviSense session - ${payload.childName}`,

      description: "Therapy session updated from NaiviSense.",

      start: {
        dateTime: scheduledAt.toISOString(),
      },

      end: {
        dateTime: endAt.toISOString(),
      },

      attendees,
    },
  });

  return {

    calendar_event_id:
      updatedEvent.data.id ?? payload.eventId,

    meeting_link:
      eventMeetingLink(updatedEvent.data) ?? "",

    calendar_provider: "google",
  };
}

export async function deleteCalendarEvent(
  eventId: string
): Promise<void> {

  const calendar = getCalendarClient();

  if (!calendar) {
    throw new AppError(
      "SERVICE_UNAVAILABLE",
      "Google Calendar is not configured"
    );
  }

  await calendar.events.delete({
    calendarId: env.GOOGLE_CALENDAR_ID,
    eventId,
    sendUpdates: "all",
  });

}



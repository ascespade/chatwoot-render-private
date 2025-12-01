# frozen_string_literal: true

module Clinic
  class GoogleCalendarSyncService
    # Google Calendar API integration
    # Requires: google-apis-calendar_v3 gem
    # Optional - will gracefully handle if not configured

    attr_reader :appointment

    def initialize(appointment)
      @appointment = appointment
      @account = appointment.account
      @doctor = appointment.doctor
    end

    def sync
      return unless @doctor.google_calendar_id.present?
      return unless google_calendar_configured?

      if appointment.google_calendar_event_id.present?
        update_event
      else
        create_event
      end
    end

    def delete_event
      return unless appointment.google_calendar_event_id.present?
      return unless google_calendar_configured?

      service.delete_event(@doctor.google_calendar_id, appointment.google_calendar_event_id)
      appointment.update_column(:google_calendar_event_id, nil)
    rescue StandardError => e
      Rails.logger.error("Failed to delete Google Calendar event: #{e.message}")
      raise
    end

    private

    def google_calendar_configured?
      ENV['GOOGLE_CALENDAR_CLIENT_ID'].present? &&
        ENV['GOOGLE_CALENDAR_CLIENT_SECRET'].present? &&
        @doctor.google_calendar_id.present?
    end

    def service
      @service ||= begin
        calendar = Google::Apis::CalendarV3::CalendarService.new
        calendar.authorization = authorize
        calendar
      end
    end

    def authorize
      credentials = Google::Auth::ServiceAccountCredentials.make_creds(
        json_key_io: StringIO.new(ENV['GOOGLE_CALENDAR_SERVICE_ACCOUNT_JSON']),
        scope: Google::Apis::CalendarV3::AUTH_CALENDAR
      )
      credentials.fetch_access_token!
      credentials
    end

    def create_event
      event = build_event
      result = service.insert_event(@doctor.google_calendar_id, event)
      appointment.update_column(:google_calendar_event_id, result.id)
      result
    end

    def update_event
      event = service.get_event(@doctor.google_calendar_id, appointment.google_calendar_event_id)
      update_event_details(event)
      service.update_event(@doctor.google_calendar_id, appointment.google_calendar_event_id, event)
    end

    def build_event
      Google::Apis::CalendarV3::Event.new(
        summary: "Appointment with #{@appointment.contact.name}",
        description: build_event_description,
        start: build_time_object(@appointment.scheduled_at),
        end: build_time_object(@appointment.ends_at),
        attendees: [
          Google::Apis::CalendarV3::EventAttendee.new(email: @appointment.contact.email),
          Google::Apis::CalendarV3::EventAttendee.new(email: @doctor.email)
        ].compact,
        reminders: {
          use_default: false,
          overrides: [
            { method: 'popup', minutes: 24 * 60 },
            { method: 'popup', minutes: 2 * 60 }
          ]
        }
      )
    end

    def update_event_details(event)
      event.summary = "Appointment with #{@appointment.contact.name}"
      event.description = build_event_description
      event.start = build_time_object(@appointment.scheduled_at)
      event.end = build_time_object(@appointment.ends_at)
    end

    def build_time_object(time)
      Google::Apis::CalendarV3::EventDateTime.new(
        date_time: time.iso8601,
        time_zone: @account.timezone || 'UTC'
      )
    end

    def build_event_description
      parts = []
      parts << "Patient: #{@appointment.contact.name}"
      parts << "Phone: #{@appointment.contact.phone_number}" if @appointment.contact.phone_number
      parts << "Notes: #{@appointment.notes}" if @appointment.notes.present?
      parts << "\nBooked via Chatwoot Clinic System"
      parts.join("\n")
    end
  end
end


# frozen_string_literal: true

module Clinic
  class AppointmentService
    attr_reader :account, :errors

    def initialize(account)
      @account = account
      @errors = []
    end

    def create_appointment(params)
      doctor = account.doctors.find(params[:doctor_id])
      contact = account.contacts.find(params[:contact_id])
      conversation = params[:conversation_id] ? account.conversations.find(params[:conversation_id]) : nil

      # Check availability
      unless doctor.available_at?(params[:scheduled_at])
        @errors << "Doctor is not available at this time"
        return nil
      end

      # Check for conflicts
      if conflicting_appointment?(doctor, params[:scheduled_at], params[:duration_minutes] || 30)
        @errors << "Time slot is already booked"
        return nil
      end

      appointment = Appointment.create!(
        account: account,
        doctor: doctor,
        contact: contact,
        conversation: conversation,
        scheduled_at: params[:scheduled_at],
        duration_minutes: params[:duration_minutes] || 30,
        status: params[:status] || 'scheduled',
        notes: params[:notes],
        metadata: params[:metadata] || {}
      )

      # Sync with Google Calendar if configured
      sync_to_google_calendar(appointment) if doctor.google_calendar_id.present?

      # Schedule reminders
      appointment.schedule_reminders if appointment.status == 'confirmed'

      appointment
    rescue ActiveRecord::RecordInvalid => e
      @errors << e.message
      nil
    end

    def update_appointment(appointment, params)
      old_time = appointment.scheduled_at

      appointment.update!(params)

      # Reschedule reminders if time changed
      if old_time != appointment.scheduled_at
        appointment.appointment_reminders.where(status: 'pending').destroy_all
        appointment.schedule_reminders if appointment.status == 'confirmed'
      end

      appointment
    end

    private

    def conflicting_appointment?(doctor, scheduled_at, duration_minutes)
      ends_at = scheduled_at + duration_minutes.minutes
      
      Appointment
        .where(doctor: doctor)
        .where(status: %w[scheduled confirmed])
        .where.not(id: nil) # Exclude current appointment if updating
        .where(
          '(scheduled_at < ? AND ends_at > ?) OR (scheduled_at < ? AND ends_at > ?)',
          ends_at, scheduled_at,
          scheduled_at, scheduled_at
        )
        .exists?
    end

    def sync_to_google_calendar(appointment)
      Clinic::GoogleCalendarSyncService.new(appointment).sync
    rescue StandardError => e
      Rails.logger.error("Failed to sync appointment to Google Calendar: #{e.message}")
      # Don't fail appointment creation if calendar sync fails
    end
  end
end


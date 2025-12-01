# frozen_string_literal: true

module Clinic
  class ReminderService
    attr_reader :reminder

    def initialize(reminder)
      @reminder = reminder
      @appointment = reminder.appointment
      @account = @appointment.account
      @contact = @appointment.contact
      @doctor = @appointment.doctor
    end

    def send
      case reminder.channel
      when 'whatsapp'
        send_whatsapp_reminder
      when 'email'
        send_email_reminder
      when 'sms'
        send_sms_reminder
      else
        { success: false, error: "Unknown channel: #{reminder.channel}" }
      end
    end

    private

    def send_whatsapp_reminder
      # Find WhatsApp inbox for this account
      whatsapp_inbox = @account.inboxes.joins(:channel).find_by(channels: { type: 'Channel::Whatsapp' })
      return { success: false, error: 'WhatsApp inbox not found' } unless whatsapp_inbox

      # Find or create contact inbox
      contact_inbox = @contact.contact_inboxes.find_by(inbox: whatsapp_inbox)
      if contact_inbox.nil?
        # Create conversation if needed
        conversation = whatsapp_inbox.conversations.find_or_create_by(contact: @contact)
        contact_inbox = ContactInbox.create!(contact: @contact, inbox: whatsapp_inbox, source_id: @contact.phone_number)
      end

      message_content = build_reminder_message

      # Send message via WhatsApp channel
      whatsapp_channel = whatsapp_inbox.channel
      whatsapp_channel.send_message(contact_inbox.source_id, message_content)

      { success: true }
    rescue StandardError => e
      { success: false, error: e.message }
    end

    def send_email_reminder
      return { success: false, error: 'Contact email not found' } unless @contact.email.present?

      Clinic::ReminderMailer.appointment_reminder(@appointment, reminder.reminder_type).deliver_now
      { success: true }
    rescue StandardError => e
      { success: false, error: e.message }
    end

    def send_sms_reminder
      # SMS reminder via Twilio or similar
      # Implementation depends on your SMS provider
      { success: false, error: 'SMS reminders not yet implemented' }
    end

    def build_reminder_message
      hours = reminder.reminder_type == '24h_before' ? '24' : '2'
      formatted_time = @appointment.scheduled_at.strftime('%B %d, %Y at %I:%M %p')
      
      <<~MESSAGE
        🔔 Appointment Reminder
        
        Hi #{@contact.name},
        
        This is a reminder that you have an appointment with Dr. #{@doctor.name} in #{hours} hours.
        
        📅 Date & Time: #{formatted_time}
        👨‍⚕️ Doctor: #{@doctor.display_name}
        
        Please arrive 10 minutes early.
        
        Reply CANCEL to cancel or RESCHEDULE to reschedule.
      MESSAGE
    end
  end
end


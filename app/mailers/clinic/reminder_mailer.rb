# frozen_string_literal: true

module Clinic
  class ReminderMailer < ApplicationMailer
    def appointment_reminder(appointment, reminder_type)
      @appointment = appointment
      @reminder_type = reminder_type
      @contact = appointment.contact
      @doctor = appointment.doctor
      
      hours = reminder_type == '24h_before' ? '24' : '2'
      subject = "Appointment Reminder - #{hours} hours"
      
      mail(
        to: @contact.email,
        subject: subject
      )
    end
  end
end


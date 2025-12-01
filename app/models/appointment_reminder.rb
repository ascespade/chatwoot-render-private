# frozen_string_literal: true

class AppointmentReminder < ApplicationRecord
  belongs_to :appointment

  validates :reminder_type, inclusion: { in: %w[24h_before 2h_before] }
  validates :channel, inclusion: { in: %w[whatsapp email sms] }
  validates :status, inclusion: { in: %w[pending sent failed cancelled] }

  scope :pending, -> { where(status: 'pending') }
  scope :due, -> { where('scheduled_for <= ?', Time.current).where(status: 'pending') }

  def send!
    result = Clinic::ReminderService.new(self).send
    if result[:success]
      update!(status: 'sent', sent_at: Time.current)
      update_appointment_tracking
    else
      update!(status: 'failed', error_message: result[:error])
    end
  end

  private

  def update_appointment_tracking
    field = reminder_type == '24h_before' ? 'reminder_sent_at_24h' : 'reminder_sent_at_2h'
    appointment.update_column(field, Time.current.to_s)
  end
end


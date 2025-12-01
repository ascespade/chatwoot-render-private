# frozen_string_literal: true

class Appointment < ApplicationRecord
  belongs_to :account
  belongs_to :doctor
  belongs_to :contact
  belongs_to :conversation, optional: true
  has_many :appointment_reminders, dependent: :destroy

  validates :scheduled_at, presence: true
  validates :status, inclusion: { in: %w[scheduled confirmed completed cancelled no_show] }

  before_save :calculate_ends_at

  scope :upcoming, -> { where('scheduled_at > ?', Time.current).where(status: %w[scheduled confirmed]) }
  scope :today, -> { where('scheduled_at::date = ?', Date.current) }
  scope :by_status, ->(status) { where(status: status) }

  def confirm!
    update!(status: 'confirmed')
    schedule_reminders
  end

  def complete!
    update!(status: 'completed')
  end

  def cancel!(reason = nil)
    update!(status: 'cancelled', notes: [notes, "Cancelled: #{reason}"].compact.join("\n"))
    cancel_reminders
  end

  def needs_reminder_24h?
    return false if reminder_sent_at_24h.present?
    return false if scheduled_at < 24.hours.from_now

    scheduled_at >= 24.hours.from_now && scheduled_at <= 25.hours.from_now
  end

  def needs_reminder_2h?
    return false if reminder_sent_at_2h.present?
    return false if scheduled_at < 2.hours.from_now

    scheduled_at >= 2.hours.from_now && scheduled_at <= 3.hours.from_now
  end

  private

  def calculate_ends_at
    self.ends_at = scheduled_at + duration_minutes.minutes if scheduled_at.present? && duration_minutes.present?
  end

  def schedule_reminders
    # Schedule 24h reminder
    if needs_reminder_24h?
      appointment_reminders.create!(
        reminder_type: '24h_before',
        scheduled_for: scheduled_at - 24.hours,
        status: 'pending'
      )
    end

    # Schedule 2h reminder
    if needs_reminder_2h?
      appointment_reminders.create!(
        reminder_type: '2h_before',
        scheduled_for: scheduled_at - 2.hours,
        status: 'pending'
      )
    end
  end

  def cancel_reminders
    appointment_reminders.where(status: 'pending').update_all(status: 'cancelled')
  end
end


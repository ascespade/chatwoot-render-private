# frozen_string_literal: true

class Doctor < ApplicationRecord
  belongs_to :account
  has_many :appointments, dependent: :destroy

  validates :name, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :email, uniqueness: { scope: :account_id }, allow_blank: true

  scope :active, -> { where(active: true) }

  def display_name
    specialization.present? ? "#{name} - #{specialization}" : name
  end

  def available_at?(datetime)
    # Check if doctor is available at given datetime
    # This can be enhanced with working_hours logic
    working_hours.present? ? check_working_hours(datetime) : true
  end

  private

  def check_working_hours(datetime)
    day_name = datetime.strftime('%A').downcase
    hours = working_hours[day_name]
    return false unless hours

    time = datetime.strftime('%H:%M')
    hours['start'] <= time && time <= hours['end']
  end
end


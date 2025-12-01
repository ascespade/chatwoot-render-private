# frozen_string_literal: true

class Clinic::SendAppointmentRemindersJob < ApplicationJob
  queue_as :default

  def perform
    # Find reminders that are due
    AppointmentReminder.due.find_each do |reminder|
      reminder.send!
    end
  end
end


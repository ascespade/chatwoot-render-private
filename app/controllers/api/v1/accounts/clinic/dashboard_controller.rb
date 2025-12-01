# frozen_string_literal: true

module Api
  module V1
    module Accounts
      module Clinic
        class DashboardController < Api::V1::Accounts::BaseController
          def show
            data = {
              appointments_today: appointments_today_count,
              upcoming_appointments: upcoming_appointments_data,
              ai_vs_human_count: ai_vs_human_conversations,
              recent_appointments: recent_appointments_data,
              stats: {
                total_appointments: Current.account.appointments.count,
                confirmed_appointments: Current.account.appointments.by_status('confirmed').count,
                completed_today: Current.account.appointments.by_status('completed').today.count,
                cancelled_today: Current.account.appointments.by_status('cancelled').today.count
              }
            }
            render json: data
          end

          private

          def appointments_today_count
            Current.account.appointments.today.count
          end

          def upcoming_appointments_data
            Current.account.appointments
              .upcoming
              .limit(10)
              .includes(:doctor, :contact)
              .map do |appt|
                {
                  id: appt.id,
                  scheduled_at: appt.scheduled_at,
                  doctor_name: appt.doctor.name,
                  patient_name: appt.contact.name,
                  status: appt.status
                }
              end
          end

          def ai_vs_human_conversations
            # Count conversations handled by AI vs human
            # This is a simplified version - can be enhanced with actual AI detection
            total = Current.account.conversations.where(created_at: 24.hours.ago..).count
            {
              total: total,
              ai_handled: 0, # Placeholder - implement based on your AI detection logic
              human_handled: total
            }
          end

          def recent_appointments_data
            Current.account.appointments
              .includes(:doctor, :contact)
              .order(scheduled_at: :desc)
              .limit(5)
              .map do |appt|
                {
                  id: appt.id,
                  scheduled_at: appt.scheduled_at,
                  doctor_name: appt.doctor.name,
                  patient_name: appt.contact.name,
                  status: appt.status,
                  contact_phone: appt.contact.phone_number
                }
              end
          end
        end
      end
    end
  end
end


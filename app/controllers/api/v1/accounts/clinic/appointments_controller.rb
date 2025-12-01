# frozen_string_literal: true

module Api
  module V1
    module Accounts
      module Clinic
        class AppointmentsController < Api::V1::Accounts::BaseController
          before_action :check_account_features
          before_action :set_appointment, only: [:show, :update, :destroy, :confirm, :complete, :cancel]

          def index
            @appointments = Current.account.appointments
              .includes(:doctor, :contact, :conversation)
              .order(scheduled_at: :asc)

            @appointments = filter_appointments(@appointments)
            render json: @appointments, include: [:doctor, :contact]
          end

          def show
            render json: @appointment, include: [:doctor, :contact, :conversation, :appointment_reminders]
          end

          def create
            service = Clinic::AppointmentService.new(Current.account)
            @appointment = service.create_appointment(appointment_params)

            if @appointment
              render json: @appointment, status: :created, include: [:doctor, :contact]
            else
              render json: { errors: service.errors }, status: :unprocessable_entity
            end
          end

          def update
            service = Clinic::AppointmentService.new(Current.account)
            @appointment = service.update_appointment(@appointment, appointment_params)

            if @appointment.errors.empty?
              render json: @appointment, include: [:doctor, :contact]
            else
              render json: { errors: @appointment.errors.full_messages }, status: :unprocessable_entity
            end
          end

          def destroy
            @appointment.destroy
            head :no_content
          end

          def confirm
            @appointment.confirm!
            render json: @appointment, include: [:doctor, :contact]
          end

          def complete
            @appointment.complete!
            render json: @appointment
          end

          def cancel
            @appointment.cancel!(params[:reason])
            render json: @appointment
          end

          def today
            @appointments = Current.account.appointments
              .includes(:doctor, :contact)
              .today
              .order(scheduled_at: :asc)
            render json: @appointments, include: [:doctor, :contact]
          end

          def upcoming
            @appointments = Current.account.appointments
              .includes(:doctor, :contact)
              .upcoming
              .order(scheduled_at: :asc)
            render json: @appointments, include: [:doctor, :contact]
          end

          private

          def set_appointment
            @appointment = Current.account.appointments.find(params[:id])
          end

          def appointment_params
            params.require(:appointment).permit(
              :doctor_id, :contact_id, :conversation_id, :scheduled_at,
              :duration_minutes, :status, :notes, metadata: {}
            )
          end

          def filter_appointments(appointments)
            appointments = appointments.where(doctor_id: params[:doctor_id]) if params[:doctor_id].present?
            appointments = appointments.where(status: params[:status]) if params[:status].present?
            appointments = appointments.where('scheduled_at >= ?', params[:start_date]) if params[:start_date].present?
            appointments = appointments.where('scheduled_at <= ?', params[:end_date]) if params[:end_date].present?
            appointments
          end

          def check_account_features
            # Feature flag check can be added here if needed
          end
        end
      end
    end
  end
end


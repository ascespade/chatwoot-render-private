# frozen_string_literal: true

module Api
  module V1
    module Accounts
      module Clinic
        class DoctorsController < Api::V1::Accounts::BaseController
          before_action :check_account_features
          before_action :set_doctor, only: [:show, :update, :destroy]

          def index
            @doctors = Current.account.doctors.active
              .order(:name)
            render json: @doctors
          end

          def show
            render json: @doctor
          end

          def create
            @doctor = Current.account.doctors.build(doctor_params)

            if @doctor.save
              render json: @doctor, status: :created
            else
              render json: { errors: @doctor.errors.full_messages }, status: :unprocessable_entity
            end
          end

          def update
            if @doctor.update(doctor_params)
              render json: @doctor
            else
              render json: { errors: @doctor.errors.full_messages }, status: :unprocessable_entity
            end
          end

          def destroy
            @doctor.update(active: false)
            head :no_content
          end

          private

          def set_doctor
            @doctor = Current.account.doctors.find(params[:id])
          end

          def doctor_params
            params.require(:doctor).permit(
              :name, :specialization, :email, :phone,
              :google_calendar_id, :bio, :active,
              working_hours: {}
            )
          end

          def check_account_features
            # Feature flag check can be added here if needed
          end
        end
      end
    end
  end
end


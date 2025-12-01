# frozen_string_literal: true

class SuperAdmin::AppointmentsController < SuperAdmin::ApplicationController
  # Administrate will handle CRUD operations automatically
  
  # Add custom actions for appointment management
  def confirm
    requested_resource.confirm!
    redirect_to [namespace, requested_resource], notice: 'Appointment confirmed'
  end

  def complete
    requested_resource.complete!
    redirect_to [namespace, requested_resource], notice: 'Appointment marked as completed'
  end

  def cancel
    requested_resource.cancel!(params[:reason])
    redirect_to [namespace, requested_resource], notice: 'Appointment cancelled'
  end
end


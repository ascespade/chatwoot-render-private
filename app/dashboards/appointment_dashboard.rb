require 'administrate/base_dashboard'

class AppointmentDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::Number.with_options(searchable: true),
    account: Field::BelongsToSearch.with_options(
      class_name: 'Account',
      searchable: true,
      searchable_field: [:name, :id],
      order: 'id DESC'
    ),
    doctor: Field::BelongsTo,
    contact: Field::BelongsTo,
    conversation: Field::BelongsTo.with_options(required: false),
    scheduled_at: Field::DateTime,
    ends_at: Field::DateTime,
    duration_minutes: Field::Number,
    status: Field::Select.with_options(
      collection: %w[scheduled confirmed completed cancelled no_show]
    ),
    notes: Field::Text,
    google_calendar_event_id: Field::String,
    reminder_sent_at_24h: Field::String,
    reminder_sent_at_2h: Field::String,
    metadata: Field::JSON,
    appointment_reminders: Field::HasMany,
    created_at: Field::DateTime,
    updated_at: Field::DateTime
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    id
    account
    doctor
    contact
    scheduled_at
    status
    duration_minutes
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    account
    doctor
    contact
    conversation
    scheduled_at
    ends_at
    duration_minutes
    status
    notes
    google_calendar_event_id
    reminder_sent_at_24h
    reminder_sent_at_2h
    metadata
    appointment_reminders
    created_at
    updated_at
  ].freeze

  FORM_ATTRIBUTES = %i[
    account
    doctor
    contact
    conversation
    scheduled_at
    duration_minutes
    status
    notes
    metadata
  ].freeze

  COLLECTION_FILTERS = {
    scheduled: ->(resources) { resources.where(status: 'scheduled') },
    confirmed: ->(resources) { resources.where(status: 'confirmed') },
    completed: ->(resources) { resources.where(status: 'completed') },
    cancelled: ->(resources) { resources.where(status: 'cancelled') },
    today: ->(resources) { resources.where('scheduled_at::date = ?', Date.current) },
    upcoming: ->(resources) { resources.where('scheduled_at > ?', Time.current) }
  }.freeze

  def display_resource(appointment)
    "#{appointment.doctor.name} - #{appointment.contact.name} (#{appointment.scheduled_at.strftime('%Y-%m-%d %H:%M')})"
  end
end


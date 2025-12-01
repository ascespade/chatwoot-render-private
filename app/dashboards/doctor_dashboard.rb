require 'administrate/base_dashboard'

class DoctorDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::Number.with_options(searchable: true),
    account: Field::BelongsToSearch.with_options(
      class_name: 'Account',
      searchable: true,
      searchable_field: [:name, :id],
      order: 'id DESC'
    ),
    name: Field::String.with_options(searchable: true),
    specialization: Field::String.with_options(searchable: true),
    email: Field::String.with_options(searchable: true),
    phone: Field::String,
    google_calendar_id: Field::String,
    working_hours: Field::Text,
    bio: Field::Text,
    active: Field::Boolean,
    appointments: CountField,
    created_at: Field::DateTime,
    updated_at: Field::DateTime
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    id
    account
    name
    specialization
    email
    active
    appointments
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    account
    name
    specialization
    email
    phone
    google_calendar_id
    working_hours
    bio
    active
    appointments
    created_at
    updated_at
  ].freeze

  FORM_ATTRIBUTES = %i[
    account
    name
    specialization
    email
    phone
    google_calendar_id
    working_hours
    bio
    active
  ].freeze

  COLLECTION_FILTERS = {
    active: ->(resources) { resources.where(active: true) },
    inactive: ->(resources) { resources.where(active: false) }
  }.freeze

  def display_resource(doctor)
    "#{doctor.name} (#{doctor.specialization})"
  end
end


class CreateClinicTables < ActiveRecord::Migration[7.0]
  def change
    # Doctors table
    create_table :doctors do |t|
      t.references :account, null: false, foreign_key: true
      t.string :name, null: false
      t.string :specialization
      t.string :email
      t.string :phone
      t.string :google_calendar_id
      t.jsonb :working_hours, default: {}
      t.text :bio
      t.boolean :active, default: true
      t.timestamps

      t.index [:account_id, :email], unique: true
    end

    # Appointments table
    create_table :appointments do |t|
      t.references :account, null: false, foreign_key: true
      t.references :doctor, null: false, foreign_key: true
      t.references :contact, null: false, foreign_key: true
      t.references :conversation, null: true, foreign_key: true
      t.datetime :scheduled_at, null: false
      t.datetime :ends_at
      t.integer :duration_minutes, default: 30
      t.string :status, default: 'scheduled' # scheduled, confirmed, completed, cancelled, no_show
      t.text :notes
      t.string :google_calendar_event_id
      t.string :reminder_sent_at_24h
      t.string :reminder_sent_at_2h
      t.jsonb :metadata, default: {}
      t.timestamps

      t.index [:account_id, :scheduled_at]
      t.index [:doctor_id, :scheduled_at]
      t.index [:contact_id, :scheduled_at]
      t.index :status
    end

    # Appointment reminders table (for tracking)
    create_table :appointment_reminders do |t|
      t.references :appointment, null: false, foreign_key: true
      t.string :reminder_type # 24h_before, 2h_before
      t.string :channel # whatsapp, email, sms
      t.string :status # pending, sent, failed
      t.datetime :scheduled_for
      t.datetime :sent_at
      t.text :error_message
      t.timestamps

      t.index [:appointment_id, :reminder_type]
      t.index :status
      t.index :scheduled_for
    end
  end
end


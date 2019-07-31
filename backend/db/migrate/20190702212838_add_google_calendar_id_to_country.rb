class AddGoogleCalendarIdToCountry < ActiveRecord::Migration[5.2]
  def change
    add_column :countries, :google_calendar_id, :string
    add_index :countries, :google_calendar_id
  end
end

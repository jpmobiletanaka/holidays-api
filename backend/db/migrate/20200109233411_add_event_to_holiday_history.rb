class AddEventToHolidayHistory < ActiveRecord::Migration[5.2]
  def change
    add_column :holiday_histories, :event, :string, null: false, default: 'INSERT', index: true
  end
end

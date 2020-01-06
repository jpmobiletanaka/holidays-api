class AddHolidayReferenceToSources < ActiveRecord::Migration[5.2]
  def change
    add_reference :google_raw_holidays, :holiday, index: true
    add_reference :file_raw_holidays, :holiday, index: true
  end
end



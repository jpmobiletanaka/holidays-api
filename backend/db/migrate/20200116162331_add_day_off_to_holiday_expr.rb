class AddDayOffToHolidayExpr < ActiveRecord::Migration[5.2]
  def change
    add_column :holiday_exprs, :day_off, :boolean, null: false, default: true
    HolidayExpr.update_all(day_off: true)
  end
end

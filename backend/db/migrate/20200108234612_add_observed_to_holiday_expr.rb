class AddObservedToHolidayExpr < ActiveRecord::Migration[5.2]
  def change
    add_column :holiday_exprs, :observed, :boolean
  end
end

class ChangeHolidayExprObservedDefaultToFalse < ActiveRecord::Migration[5.2]
  def change
    change_column :holiday_exprs, :observed, :boolean, default: false
  end
end

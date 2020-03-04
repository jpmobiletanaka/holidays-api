class ChangeHolidayExprObservedDefaultToFalse < ActiveRecord::Migration[5.2]
  def change
    HolidayExpr.where(observed: nil).update_all(observed: false)
    change_column :holiday_exprs, :observed, :boolean, null: false, default: false
  end
end

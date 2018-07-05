class AddUniqueIndexToHolidays < ActiveRecord::Migration[5.2]
  def change
    add_index :holidays, %i[holiday_expr_id country_code date], unique: true
  end
end

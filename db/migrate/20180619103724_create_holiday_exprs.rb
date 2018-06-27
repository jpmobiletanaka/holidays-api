class CreateHolidayExprs < ActiveRecord::Migration[5.2]
  def change
    create_table :holiday_exprs do |t|
      t.string  :ja_name
      t.string  :en_name
      t.string  :country_code,  null: false
      t.string  :expression,    null: false
      t.integer :calendar_type, null: false, default: 0, limit: 1
      t.integer :holiday_type,  null: false, default: 0, limit: 1
      t.boolean :processed,     null: false, default: false
      t.timestamps
    end
  end
end

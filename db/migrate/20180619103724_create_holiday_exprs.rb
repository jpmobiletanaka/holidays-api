class CreateHolidayExprs < ActiveRecord::Migration[5.2]
  def change
    create_table :holiday_exprs do |t|
      t.string  :ja_name,       null: false, limit: 100
      t.string  :en_name,       null: false, limit: 100
      t.string  :country_code,  null: false, index: true, limit: 2
      t.string  :expression,    null: false, limit: 30
      t.integer :calendar_type, null: false, default: 0, limit: 1, index: true
      t.integer :holiday_type,  null: false, default: 0, limit: 1, index: true
      t.boolean :processed,     null: false, default: false, index: true
      t.timestamps
    end

    add_index :holiday_exprs, %i[ja_name en_name country_code expression],
                              name: 'main_unique_index_on_holiday_exprs',
                              unique: true
  end
end

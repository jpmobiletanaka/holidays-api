class CreateFileRawHolidays < ActiveRecord::Migration[5.2]
  def change
    create_table :file_raw_holidays do |t|
      t.string :en_name, null: false
      t.string :ja_name, null: false
      t.boolean :observed
      t.date :moved_from
      t.boolean :day_off
      t.date :date, null: false
      t.string :country, null: false
      t.references :holiday, index: true
      t.string :state, default: 'pending', null: false, index: true
      t.jsonb :error

      t.timestamps
    end

    add_index :file_raw_holidays, %i[en_name date country observed], unique: true, name: :en_name_upsert_constraint
    add_index :file_raw_holidays, %i[ja_name date country observed], unique: true, name: :ja_name_upsert_constraint
  end
end

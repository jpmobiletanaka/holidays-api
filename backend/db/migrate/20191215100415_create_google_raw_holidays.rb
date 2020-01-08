class CreateGoogleRawHolidays < ActiveRecord::Migration[5.2]
  def change
    create_table :google_raw_holidays do |t|
      t.string :en_name, null: false
      t.string :ja_name
      t.boolean :observed
      t.date :date, null: false
      t.string :country_code, null: false
      t.string :state, default: :pending, null: false, index: true
      t.jsonb :error

      t.timestamps
    end

    add_index :google_raw_holidays, %i[en_name date country_code observed], unique: true, name: :en_upsert_constraint
    add_index :google_raw_holidays, %i[ja_name date country_code observed], unique: true, name: :ja_upsert_constraint
  end
end

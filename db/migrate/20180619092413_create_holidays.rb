class CreateHolidays < ActiveRecord::Migration[5.2]
  def change
    create_table :holidays do |t|
      t.belongs_to :holiday_expr, index: true, null: true
      t.belongs_to :moved_from,   index: true, null: true
      t.string     :country_code, index: true, null: true
      t.string     :ja_name
      t.string     :en_name
      t.date       :date
      t.integer    :source,  default: 0, limit: 1
      t.boolean    :enabled, default: true
      t.timestamps
    end

    add_index :holidays, %i[country_code date ja_name en_name], unique: true
  end
end
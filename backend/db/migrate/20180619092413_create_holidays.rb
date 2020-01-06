class CreateHolidays < ActiveRecord::Migration[5.2]
  def change
    create_table :holidays do |t|
      t.belongs_to :holiday_expr, index: true, null: true
      t.string     :country_code, index: true, null: true
      t.string     :ja_name
      t.string     :en_name
      t.integer    :current_source_type,  default: 0, limit: 1
      t.jsonb      :source_ids
      t.boolean    :enabled, default: true
      t.boolean    :observed, default: false, null: false
      t.boolean    :day_off, default: true

      t.timestamps
    end

    add_index :holidays, %i[holiday_expr_id country_code ja_name en_name],
                         name: 'main_unique_index_on_holidays',
                         unique: true
  end
end

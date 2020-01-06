class CreateDays < ActiveRecord::Migration[5.2]
  def change
    create_table :days do |t|
      t.references :holiday, index: true, null: false
      t.belongs_to :moved_from, index: true, null: true
      t.boolean    :enabled, default: true
      t.date :date
    end

    add_index :days, %i[holiday_id date], unique: true
  end
end

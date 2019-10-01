class CreateHolidayExprHistoriesWithTrigger < ActiveRecord::Migration[5.2]
  def up
    create_table :holiday_expr_histories do |t|
      t.belongs_to :holiday_expr, index: { name: :index_on_holiday_expr_histories_belongs_to_holiday_expr },
                                   null: false,
                                   foreign_key: { on_delete: :cascade }
      t.string  :ja_name
      t.string  :en_name
      t.string  :country_code
      t.string  :expression
      t.integer :calendar_type
      t.integer :holiday_type
      t.boolean :processed
      t.datetime :date
    end

    execute('DROP TRIGGER IF EXISTS holiday_expr_update')

    update_trigger = <<-SQL
      CREATE TRIGGER `holiday_expr_update` AFTER UPDATE ON `holiday_exprs`
      FOR EACH ROW
      BEGIN
        INSERT INTO `holiday_expr_histories` (`holiday_expr_id`, `date`, `ja_name`, `en_name`, `country_code`, `expression`, `calendar_type`, `holiday_type`, `processed`)
          VALUES (NEW.id, NEW.updated_at, NEW.ja_name, NEW.en_name, NEW.country_code, NEW.expression, NEW.calendar_type, NEW.holiday_type, NEW.processed );
      END
    SQL

    execute(update_trigger)
  end

  def down
    drop_table :holiday_expr_histories
    execute('DROP TRIGGER IF EXISTS holiday_expr_update')
  end
end

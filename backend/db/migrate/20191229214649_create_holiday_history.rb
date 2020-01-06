class CreateHolidayHistory < ActiveRecord::Migration[5.2]
  def up
    create_table :holiday_histories do |t|
      t.references :holiday, index: true
      t.integer    :holiday_expr_id, index: true, null: true
      t.string     :country_code, index: true, null: true
      t.string     :ja_name
      t.string     :en_name
      t.integer    :current_source_type, limit: 1
      t.jsonb      :source_ids
      t.boolean    :enabled
      t.boolean    :observed
      t.boolean    :day_off

      t.datetime   :date
    end

    execute('DROP TRIGGER IF EXISTS on_holiday_update ON holidays')

    create_history_function = <<~SQL
      CREATE OR REPLACE FUNCTION create_holiday_history() RETURNS TRIGGER AS $$
          BEGIN
            INSERT INTO holiday_histories (holiday_id, holiday_expr_id, country_code, ja_name, en_name, current_source_type, source_ids, enabled, observed, day_off, date)
              VALUES (NEW.id, NEW.holiday_expr_id, NEW.country_code, NEW.ja_name, NEW.en_name, NEW.current_source_type, NEW.source_ids, NEW.enabled, NEW.observed, NEW.day_off, NEW.updated_at);
            RETURN NULL;
          END
        $$ LANGUAGE plpgsql
    SQL

    history_trigger_on_create = <<~SQL
      CREATE TRIGGER on_holiday_create
        AFTER INSERT ON holidays
        FOR EACH ROW EXECUTE PROCEDURE create_holiday_history();
    SQL

    history_trigger_on_update = <<~SQL
      CREATE TRIGGER on_holiday_update
        AFTER UPDATE ON holidays
        FOR EACH ROW EXECUTE PROCEDURE create_holiday_history();
    SQL


    execute(create_history_function)
    execute(history_trigger_on_create)
    execute(history_trigger_on_update)
  end

  def down
    execute('DROP TRIGGER IF EXISTS on_holiday_update ON holidays')
    execute('DROP TRIGGER IF EXISTS on_holiday_create ON holidays')
    drop_table :holiday_histories
  end
end

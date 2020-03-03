class UpdateTriggersToSupportDestroy < ActiveRecord::Migration[5.2]
  def up
    execute('DROP TRIGGER IF EXISTS on_holiday_update ON holidays')
    execute('DROP TRIGGER IF EXISTS on_holiday_create ON holidays')

    execute(history_function)
    execute(history_function_on_destroy)
    execute(trigger_on_create)
    execute(trigger_on_update)
    execute(trigger_on_destroy)
  end

  def down
    execute('DROP TRIGGER IF EXISTS on_holiday_update ON holidays')
    execute('DROP TRIGGER IF EXISTS on_holiday_create ON holidays')
    execute('DROP TRIGGER IF EXISTS on_holiday_destroy ON holidays')

    execute(history_function)
    execute(trigger_on_create)
    execute(trigger_on_update)
  end

  def history_function
    <<~SQL
      CREATE OR REPLACE FUNCTION create_holiday_history() RETURNS TRIGGER AS $$
          BEGIN
            INSERT INTO holiday_histories (holiday_id, holiday_expr_id, country_code, ja_name, en_name, current_source_type, source_ids, enabled, observed, day_off, date, event)
              VALUES (NEW.id, NEW.holiday_expr_id, NEW.country_code, NEW.ja_name, NEW.en_name, NEW.current_source_type, NEW.source_ids, NEW.enabled, NEW.observed, NEW.day_off, NEW.updated_at, TG_OP);
            RETURN NULL;
          END
        $$ LANGUAGE plpgsql
    SQL
  end

  def history_function_on_destroy
    <<~SQL
      CREATE OR REPLACE FUNCTION create_holiday_history_on_delete() RETURNS TRIGGER AS $$
          BEGIN
            INSERT INTO holiday_histories (holiday_id, holiday_expr_id, country_code, ja_name, en_name, current_source_type, source_ids, enabled, observed, day_off, date, event)
              VALUES (OLD.id, OLD.holiday_expr_id, OLD.country_code, OLD.ja_name, OLD.en_name, OLD.current_source_type, OLD.source_ids, OLD.enabled, OLD.observed, OLD.day_off, OLD.updated_at, TG_OP);
            RETURN OLD;
          END
        $$ LANGUAGE plpgsql
    SQL
  end

  def trigger_on_create
    <<~SQL
      CREATE TRIGGER on_holiday_create
        AFTER INSERT ON holidays
        FOR EACH ROW EXECUTE PROCEDURE create_holiday_history();
    SQL
  end

  def trigger_on_update
    <<~SQL
      CREATE TRIGGER on_holiday_update
        AFTER UPDATE ON holidays
        FOR EACH ROW EXECUTE PROCEDURE create_holiday_history();
    SQL
  end

  def trigger_on_destroy
    <<~SQL
      CREATE TRIGGER on_holiday_destroy
        BEFORE DELETE ON holidays
        FOR EACH ROW EXECUTE PROCEDURE create_holiday_history_on_delete();
    SQL
  end
end

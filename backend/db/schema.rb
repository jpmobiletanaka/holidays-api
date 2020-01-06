# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_12_29_214649) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_trgm"
  enable_extension "plpgsql"

  create_table "countries", force: :cascade do |t|
    t.string "country_code", null: false
    t.string "ja_name"
    t.string "en_name"
    t.string "google_calendar_id"
    t.index ["country_code"], name: "index_countries_on_country_code"
    t.index ["google_calendar_id"], name: "index_countries_on_google_calendar_id"
  end

  create_table "days", force: :cascade do |t|
    t.bigint "holiday_id", null: false
    t.bigint "moved_from_id"
    t.boolean "enabled", default: true
    t.date "date"
    t.index ["holiday_id", "date"], name: "index_days_on_holiday_id_and_date", unique: true
    t.index ["holiday_id"], name: "index_days_on_holiday_id"
    t.index ["moved_from_id"], name: "index_days_on_moved_from_id"
  end

  create_table "file_raw_holidays", force: :cascade do |t|
    t.string "en_name", null: false
    t.string "ja_name", null: false
    t.boolean "observed"
    t.date "moved_from"
    t.boolean "day_off"
    t.date "date", null: false
    t.string "country", null: false
    t.bigint "holiday_id"
    t.string "state", default: "pending", null: false
    t.jsonb "error"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["en_name", "date", "country", "observed"], name: "en_name_upsert_constraint", unique: true
    t.index ["holiday_id"], name: "index_file_raw_holidays_on_holiday_id"
    t.index ["ja_name", "date", "country", "observed"], name: "ja_name_upsert_constraint", unique: true
    t.index ["state"], name: "index_file_raw_holidays_on_state"
  end

  create_table "google_raw_holidays", force: :cascade do |t|
    t.string "en_name", null: false
    t.string "ja_name"
    t.boolean "observed"
    t.date "date", null: false
    t.string "country_code", null: false
    t.string "state", default: "pending", null: false
    t.jsonb "error"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "holiday_id"
    t.index ["en_name", "date", "country_code"], name: "index_google_raw_holidays_on_en_name_and_date_and_country_code", unique: true
    t.index ["holiday_id"], name: "index_google_raw_holidays_on_holiday_id"
    t.index ["ja_name", "date", "country_code"], name: "index_google_raw_holidays_on_ja_name_and_date_and_country_code", unique: true
    t.index ["state"], name: "index_google_raw_holidays_on_state"
  end

  create_table "holiday_exprs", force: :cascade do |t|
    t.string "ja_name", limit: 100, null: false
    t.string "en_name", limit: 100, null: false
    t.string "country_code", limit: 2, null: false
    t.string "expression", limit: 30, null: false
    t.integer "calendar_type", limit: 2, default: 0, null: false
    t.integer "holiday_type", limit: 2, default: 0, null: false
    t.boolean "processed", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["calendar_type"], name: "index_holiday_exprs_on_calendar_type"
    t.index ["country_code"], name: "index_holiday_exprs_on_country_code"
    t.index ["holiday_type"], name: "index_holiday_exprs_on_holiday_type"
    t.index ["ja_name", "en_name", "country_code", "expression"], name: "main_unique_index_on_holiday_exprs", unique: true
    t.index ["processed"], name: "index_holiday_exprs_on_processed"
  end

  create_table "holiday_histories", force: :cascade do |t|
    t.bigint "holiday_id"
    t.integer "holiday_expr_id"
    t.string "country_code"
    t.string "ja_name"
    t.string "en_name"
    t.integer "current_source_type", limit: 2
    t.jsonb "source_ids"
    t.boolean "enabled"
    t.boolean "observed"
    t.boolean "day_off"
    t.datetime "date"
    t.index ["country_code"], name: "index_holiday_histories_on_country_code"
    t.index ["holiday_expr_id"], name: "index_holiday_histories_on_holiday_expr_id"
    t.index ["holiday_id"], name: "index_holiday_histories_on_holiday_id"
  end

  create_table "holidays", force: :cascade do |t|
    t.bigint "holiday_expr_id"
    t.string "country_code"
    t.string "ja_name"
    t.string "en_name"
    t.integer "current_source_type", limit: 2, default: 0
    t.jsonb "source_ids"
    t.boolean "enabled", default: true
    t.boolean "observed", default: false, null: false
    t.boolean "day_off", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["country_code"], name: "index_holidays_on_country_code"
    t.index ["holiday_expr_id", "country_code", "ja_name", "en_name"], name: "main_unique_index_on_holidays", unique: true
    t.index ["holiday_expr_id"], name: "index_holidays_on_holiday_expr_id"
  end

  create_table "uploads", force: :cascade do |t|
    t.string "file"
    t.integer "status"
    t.string "type"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_uploads_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.boolean "admin", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

end

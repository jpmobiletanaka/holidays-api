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

ActiveRecord::Schema.define(version: 2019_09_07_074813) do

  create_table "countries", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "country_code", null: false
    t.string "ja_name"
    t.string "en_name"
    t.string "google_calendar_id"
    t.index ["country_code"], name: "index_countries_on_country_code"
    t.index ["google_calendar_id"], name: "index_countries_on_google_calendar_id"
  end

  create_table "days", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "holiday_id", null: false
    t.bigint "moved_from_id"
    t.boolean "enabled", default: true
    t.date "date"
    t.index ["holiday_id", "date"], name: "index_days_on_holiday_id_and_date", unique: true
    t.index ["holiday_id"], name: "index_days_on_holiday_id"
    t.index ["moved_from_id"], name: "index_days_on_moved_from_id"
  end

  create_table "holiday_expr_histories", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "holiday_expr_id", null: false
    t.string "ja_name"
    t.string "en_name"
    t.string "country_code"
    t.string "expression"
    t.integer "calendar_type"
    t.integer "holiday_type"
    t.boolean "processed"
    t.datetime "date"
    t.index ["holiday_expr_id"], name: "index_on_holiday_expr_histories_belongs_to_holiday_expr"
  end

  create_table "holiday_exprs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "ja_name", limit: 100, null: false
    t.string "en_name", limit: 100, null: false
    t.string "country_code", limit: 2, null: false
    t.string "expression", limit: 30, null: false
    t.integer "calendar_type", limit: 1, default: 0, null: false
    t.integer "holiday_type", limit: 1, default: 0, null: false
    t.boolean "processed", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["calendar_type"], name: "index_holiday_exprs_on_calendar_type"
    t.index ["country_code"], name: "index_holiday_exprs_on_country_code"
    t.index ["holiday_type"], name: "index_holiday_exprs_on_holiday_type"
    t.index ["ja_name", "en_name", "country_code", "expression"], name: "main_unique_index_on_holiday_exprs", unique: true
    t.index ["processed"], name: "index_holiday_exprs_on_processed"
  end

  create_table "holidays", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "holiday_expr_id"
    t.string "country_code"
    t.string "ja_name"
    t.string "en_name"
    t.integer "source", limit: 1, default: 0
    t.boolean "enabled", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["country_code"], name: "index_holidays_on_country_code"
    t.index ["holiday_expr_id", "country_code", "ja_name", "en_name"], name: "main_unique_index_on_holidays", unique: true
    t.index ["holiday_expr_id"], name: "index_holidays_on_holiday_expr_id"
  end

  create_table "uploads", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "file"
    t.integer "status"
    t.string "type"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_uploads_on_user_id"
  end

  create_table "users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.boolean "admin", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "days", "holidays", on_delete: :cascade
  add_foreign_key "holiday_expr_histories", "holiday_exprs", on_delete: :cascade
end

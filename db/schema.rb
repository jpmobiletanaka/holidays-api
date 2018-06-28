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

ActiveRecord::Schema.define(version: 2018_06_28_123022) do

  create_table "countries", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "country_code", null: false
    t.string "ja_name"
    t.string "en_name"
    t.index ["country_code"], name: "index_countries_on_country_code"
  end

  create_table "holiday_exprs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "ja_name"
    t.string "en_name"
    t.string "country_code", null: false
    t.string "expression", null: false
    t.integer "calendar_type", limit: 1, default: 0, null: false
    t.integer "holiday_type", limit: 1, default: 0, null: false
    t.boolean "processed", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "holidays", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "holiday_expr_id"
    t.bigint "moved_from_id"
    t.string "country_code"
    t.string "ja_name"
    t.string "en_name"
    t.date "date"
    t.integer "source", limit: 1, default: 0
    t.boolean "enabled", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["country_code", "date", "ja_name", "en_name"], name: "index_holidays_on_country_code_and_date_and_ja_name_and_en_name", unique: true
    t.index ["country_code"], name: "index_holidays_on_country_code"
    t.index ["holiday_expr_id"], name: "index_holidays_on_holiday_expr_id"
    t.index ["moved_from_id"], name: "index_holidays_on_moved_from_id"
  end

  create_table "users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.boolean "admin", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

end

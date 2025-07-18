# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_07_18_015802) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "tablefunc"

  create_table "internal", id: false, force: :cascade do |t|
    t.text "k"
    t.text "v"
  end

  create_table "ndx", id: :serial, force: :cascade do |t|
    t.timestamptz "dtg", null: false
    t.float "open", null: false
    t.float "high", null: false
    t.float "low", null: false
    t.float "close", null: false
    t.bigint "volume"
    t.index ["dtg"], name: "idtgndx"
  end

  create_table "qqq", id: :serial, force: :cascade do |t|
    t.timestamptz "dtg", null: false
    t.float "open", null: false
    t.float "high", null: false
    t.float "low", null: false
    t.float "close", null: false
    t.bigint "volume", null: false
    t.index ["dtg"], name: "dtg_idx"
  end

  create_table "spx", id: :serial, force: :cascade do |t|
    t.datetime "dtg", precision: nil, null: false
    t.decimal "open", null: false
    t.decimal "high", null: false
    t.decimal "low", null: false
    t.decimal "close", null: false
    t.bigint "volume"
    t.index ["dtg"], name: "idtgspx"
  end

  create_table "sqqq", id: :serial, force: :cascade do |t|
    t.timestamptz "dtg", null: false
    t.float "open", null: false
    t.float "high", null: false
    t.float "low", null: false
    t.float "close", null: false
    t.bigint "volume", null: false
    t.index ["dtg"], name: "idtgsqqq"
  end

  create_table "symbolmap", id: false, force: :cascade do |t|
    t.text "symbol"
    t.integer "internalid"
  end

  create_table "tqqq", id: :serial, force: :cascade do |t|
    t.timestamptz "dtg", null: false
    t.float "open", null: false
    t.float "high", null: false
    t.float "low", null: false
    t.float "close", null: false
    t.bigint "volume", null: false
    t.index ["dtg"], name: "idtgtqqq"
  end

  create_table "trades", force: :cascade do |t|
    t.timestamptz "dtg"
    t.text "symbol"
    t.timestamptz "expiry"
    t.text "side"
    t.text "effect"
    t.decimal "strike"
    t.decimal "price"
    t.integer "qty"
    t.decimal "delta"
    t.decimal "theta"
    t.decimal "gamma"
    t.decimal "vega"
    t.decimal "spot"
    t.decimal "iv"
  end

  create_table "upro", id: :serial, force: :cascade do |t|
    t.datetime "dtg", precision: nil, null: false
    t.decimal "open", null: false
    t.decimal "high", null: false
    t.decimal "low", null: false
    t.decimal "close", null: false
    t.bigint "volume", null: false
    t.index ["dtg"], name: "idtgupro"
  end

  create_table "vix", id: :serial, force: :cascade do |t|
    t.datetime "dtg", precision: nil, null: false
    t.decimal "open", null: false
    t.decimal "high", null: false
    t.decimal "low", null: false
    t.decimal "close", null: false
    t.bigint "volume"
    t.index ["dtg"], name: "idtgvix"
  end
end

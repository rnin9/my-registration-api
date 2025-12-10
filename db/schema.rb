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

ActiveRecord::Schema[7.1].define(version: 2025_12_09_063748) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "courses", force: :cascade do |t|
    t.string "title", null: false
    t.text "description", null: false
    t.datetime "start_at", null: false
    t.datetime "end_at", null: false
    t.string "status", default: "AVAILABLE", null: false
    t.integer "student_count", default: 0
    t.boolean "is_destroyed", default: false, null: false
    t.bigint "actant_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["actant_id"], name: "index_courses_on_actant_id"
    t.index ["is_destroyed"], name: "index_courses_on_is_destroyed"
    t.index ["start_at"], name: "index_courses_on_start_at"
    t.index ["status"], name: "index_courses_on_status"
  end

  create_table "payments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "amount", null: false
    t.string "method"
    t.string "status", null: false
    t.string "target_type", null: false
    t.string "target_id", null: false
    t.string "title", null: false
    t.datetime "paid_at"
    t.datetime "cancelled_at"
    t.date "valid_from", null: false
    t.date "valid_to", null: false
    t.boolean "is_destroyed", default: false, null: false
    t.bigint "actant_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["actant_id"], name: "index_payments_on_actant_id"
    t.index ["is_destroyed"], name: "index_payments_on_is_destroyed"
    t.index ["status"], name: "index_payments_on_status"
    t.index ["target_id"], name: "index_payments_on_target_id"
    t.index ["target_type", "target_id"], name: "index_payments_on_target_type_and_target_id"
    t.index ["target_type"], name: "index_payments_on_target_type"
    t.index ["valid_from"], name: "index_payments_on_valid_from"
    t.index ["valid_to"], name: "index_payments_on_valid_to"
  end

  create_table "tests", force: :cascade do |t|
    t.string "title", null: false
    t.text "description", null: false
    t.datetime "start_at", null: false
    t.datetime "end_at", null: false
    t.string "status", default: "AVAILABLE", null: false
    t.integer "examinee_count", default: 0
    t.boolean "is_destroyed", default: false, null: false
    t.bigint "actant_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["actant_id"], name: "index_tests_on_actant_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "name"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_destroyed", default: false, null: false
  end

  add_foreign_key "courses", "users", column: "actant_id"
  add_foreign_key "payments", "users", column: "actant_id"
  add_foreign_key "tests", "users", column: "actant_id"
end

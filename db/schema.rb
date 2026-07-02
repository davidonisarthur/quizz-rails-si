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

ActiveRecord::Schema[8.1].define(version: 2026_06_12_171528) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "feedbacks", force: :cascade do |t|
    t.text "body_en"
    t.text "body_pt"
    t.datetime "created_at", null: false
    t.string "kind"
    t.bigint "question_id", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id"], name: "index_feedbacks_on_question_id"
  end

  create_table "options", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "question_id", null: false
    t.string "text_en"
    t.string "text_pt"
    t.datetime "updated_at", null: false
    t.index ["question_id"], name: "index_options_on_question_id"
  end

  create_table "questions", force: :cascade do |t|
    t.text "body_en"
    t.text "body_pt"
    t.text "context_en"
    t.text "context_pt"
    t.integer "correct_index"
    t.datetime "created_at", null: false
    t.string "libras_video_url"
    t.bigint "quiz_module_id", null: false
    t.datetime "updated_at", null: false
    t.index ["quiz_module_id"], name: "index_questions_on_quiz_module_id"
  end

  create_table "quiz_attempts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "quiz_module_id", null: false
    t.integer "score"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["quiz_module_id"], name: "index_quiz_attempts_on_quiz_module_id"
    t.index ["user_id"], name: "index_quiz_attempts_on_user_id"
  end

  create_table "quiz_modules", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "slug"
    t.string "title_en"
    t.string "title_pt"
    t.boolean "unlocked"
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_quiz_modules_on_slug", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.string "name"
    t.string "password_digest"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "feedbacks", "questions"
  add_foreign_key "options", "questions"
  add_foreign_key "questions", "quiz_modules"
  add_foreign_key "quiz_attempts", "quiz_modules"
  add_foreign_key "quiz_attempts", "users"
end

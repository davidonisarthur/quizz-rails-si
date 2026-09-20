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

ActiveRecord::Schema[8.1].define(version: 2026_09_20_040000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "feedbacks", force: :cascade do |t|
    t.text "body_en"
    t.text "body_pt"
    t.datetime "created_at", null: false
    t.string "kind", null: false
    t.bigint "question_id", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id", "kind"], name: "index_feedbacks_on_question_id_and_kind", unique: true
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
    t.integer "correct_index", null: false
    t.datetime "created_at", null: false
    t.string "libras_video_url"
    t.integer "position", null: false
    t.boolean "published", default: false, null: false
    t.bigint "quiz_module_id", null: false
    t.datetime "updated_at", null: false
    t.index ["quiz_module_id", "position"], name: "index_questions_on_quiz_module_id_and_position", unique: true
    t.index ["quiz_module_id", "published"], name: "index_questions_on_quiz_module_id_and_published"
    t.index ["quiz_module_id"], name: "index_questions_on_quiz_module_id"
    t.check_constraint "correct_index >= 0 AND correct_index <= 3", name: "questions_correct_index_range"
  end

  create_table "quiz_attempts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "quiz_module_id", null: false
    t.integer "score", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["quiz_module_id"], name: "index_quiz_attempts_on_quiz_module_id"
    t.index ["user_id"], name: "index_quiz_attempts_on_user_id"
    t.check_constraint "score >= 0", name: "quiz_attempts_nonnegative_score"
  end

  create_table "quiz_modules", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "created_by_id"
    t.integer "position", null: false
    t.boolean "published", default: false, null: false
    t.string "slug"
    t.string "title_en"
    t.string "title_pt"
    t.boolean "unlocked"
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_quiz_modules_on_created_by_id"
    t.index ["position"], name: "index_quiz_modules_on_position", unique: true
    t.index ["published"], name: "index_quiz_modules_on_published"
    t.index ["slug"], name: "index_quiz_modules_on_slug", unique: true
  end

  create_table "quiz_responses", force: :cascade do |t|
    t.boolean "correct", null: false
    t.datetime "created_at", null: false
    t.bigint "question_id"
    t.bigint "quiz_attempt_id", null: false
    t.integer "selected_index", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id"], name: "index_quiz_responses_on_question_id"
    t.index ["quiz_attempt_id", "question_id"], name: "index_quiz_responses_on_quiz_attempt_id_and_question_id", unique: true
    t.index ["quiz_attempt_id"], name: "index_quiz_responses_on_quiz_attempt_id"
    t.check_constraint "selected_index >= 0 AND selected_index <= 3", name: "quiz_responses_selected_index_range"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.string "name"
    t.string "password_digest"
    t.string "role", default: "student", null: false
    t.datetime "updated_at", null: false
    t.index "lower((email)::text)", name: "index_users_on_lower_email", unique: true
    t.check_constraint "role::text = ANY (ARRAY['student'::character varying, 'teacher'::character varying]::text[])", name: "users_role_allowed"
  end

  add_foreign_key "feedbacks", "questions"
  add_foreign_key "options", "questions"
  add_foreign_key "questions", "quiz_modules"
  add_foreign_key "quiz_attempts", "quiz_modules"
  add_foreign_key "quiz_attempts", "users"
  add_foreign_key "quiz_modules", "users", column: "created_by_id"
  add_foreign_key "quiz_responses", "questions", on_delete: :nullify
  add_foreign_key "quiz_responses", "quiz_attempts"
end

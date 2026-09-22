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

ActiveRecord::Schema[8.1].define(version: 2026_09_21_163000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
    t.index ["blob_id"], name: "index_active_storage_variant_records_on_blob_id"
  end

  create_table "classroom_enrollments", force: :cascade do |t|
    t.bigint "classroom_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["classroom_id", "user_id"], name: "index_classroom_enrollments_on_classroom_id_and_user_id", unique: true
    t.index ["classroom_id"], name: "index_classroom_enrollments_on_classroom_id"
    t.index ["user_id"], name: "index_classroom_enrollments_on_user_id"
  end

  create_table "classrooms", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "teacher_id", null: false
    t.datetime "updated_at", null: false
    t.index ["teacher_id"], name: "index_classrooms_on_teacher_id"
  end

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

  create_table "module_assignments", force: :cascade do |t|
    t.bigint "classroom_id", null: false
    t.datetime "created_at", null: false
    t.bigint "quiz_module_id", null: false
    t.datetime "updated_at", null: false
    t.index ["classroom_id", "quiz_module_id"], name: "index_module_assignments_on_classroom_id_and_quiz_module_id", unique: true
    t.index ["classroom_id"], name: "index_module_assignments_on_classroom_id"
    t.index ["quiz_module_id"], name: "index_module_assignments_on_quiz_module_id"
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
    t.string "audience", default: "public", null: false
    t.datetime "created_at", null: false
    t.bigint "created_by_id"
    t.boolean "platform_default", default: false, null: false
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
    t.check_constraint "audience::text = ANY (ARRAY['public'::character varying::text, 'classroom'::character varying::text])", name: "quiz_modules_audience_allowed"
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

  create_table "study_module_assignments", force: :cascade do |t|
    t.bigint "classroom_id", null: false
    t.datetime "created_at", null: false
    t.bigint "study_module_id", null: false
    t.datetime "updated_at", null: false
    t.index ["classroom_id", "study_module_id"], name: "index_study_assignments_on_classroom_and_module", unique: true
    t.index ["classroom_id"], name: "index_study_module_assignments_on_classroom_id"
    t.index ["study_module_id"], name: "index_study_module_assignments_on_study_module_id"
  end

  create_table "study_modules", force: :cascade do |t|
    t.string "audience", default: "public", null: false
    t.text "content_en", null: false
    t.text "content_pt", null: false
    t.datetime "created_at", null: false
    t.bigint "created_by_id", null: false
    t.text "libras_content_en", null: false
    t.text "libras_content_pt", null: false
    t.boolean "platform_default", default: false, null: false
    t.integer "position", null: false
    t.boolean "published", default: false, null: false
    t.bigint "quiz_module_id"
    t.string "slug", null: false
    t.string "summary_en", null: false
    t.string "summary_pt", null: false
    t.string "title_en", null: false
    t.string "title_pt", null: false
    t.datetime "updated_at", null: false
    t.string "video_url"
    t.index ["created_by_id"], name: "index_study_modules_on_created_by_id"
    t.index ["position"], name: "index_study_modules_on_position", unique: true
    t.index ["quiz_module_id"], name: "index_study_modules_on_quiz_module_id"
    t.index ["slug"], name: "index_study_modules_on_slug", unique: true
    t.check_constraint "audience::text = ANY (ARRAY['public'::character varying, 'classroom'::character varying]::text[])", name: "study_modules_audience_allowed"
  end

  create_table "study_progresses", force: :cascade do |t|
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "last_accessed_at", null: false
    t.datetime "started_at", null: false
    t.string "study_slug", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id", "study_slug"], name: "index_study_progresses_on_user_id_and_study_slug", unique: true
    t.index ["user_id"], name: "index_study_progresses_on_user_id"
  end

  create_table "teacher_access_requests", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "reviewed_at"
    t.bigint "reviewed_by_id"
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["reviewed_by_id"], name: "index_teacher_access_requests_on_reviewed_by_id"
    t.index ["user_id"], name: "index_teacher_access_requests_on_user_id"
    t.index ["user_id"], name: "index_teacher_requests_on_pending_user", unique: true, where: "((status)::text = 'pending'::text)"
    t.check_constraint "status::text = ANY (ARRAY['pending'::character varying::text, 'approved'::character varying::text, 'rejected'::character varying::text])", name: "teacher_access_requests_status_allowed"
  end

  create_table "teacher_invitations", force: :cascade do |t|
    t.datetime "accepted_at"
    t.bigint "accepted_by_id"
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.datetime "expires_at", null: false
    t.bigint "invited_by_id", null: false
    t.string "token_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["accepted_by_id"], name: "index_teacher_invitations_on_accepted_by_id"
    t.index ["invited_by_id"], name: "index_teacher_invitations_on_invited_by_id"
    t.index ["token_digest"], name: "index_teacher_invitations_on_token_digest", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.string "name"
    t.string "password_digest"
    t.string "role", default: "student", null: false
    t.datetime "updated_at", null: false
    t.index "lower((email)::text)", name: "index_users_on_lower_email", unique: true
    t.check_constraint "role::text = ANY (ARRAY['student'::character varying::text, 'teacher'::character varying::text, 'admin'::character varying::text])", name: "users_role_allowed"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "classroom_enrollments", "classrooms"
  add_foreign_key "classroom_enrollments", "users"
  add_foreign_key "classrooms", "users", column: "teacher_id"
  add_foreign_key "feedbacks", "questions"
  add_foreign_key "module_assignments", "classrooms"
  add_foreign_key "module_assignments", "quiz_modules"
  add_foreign_key "options", "questions"
  add_foreign_key "questions", "quiz_modules"
  add_foreign_key "quiz_attempts", "quiz_modules"
  add_foreign_key "quiz_attempts", "users"
  add_foreign_key "quiz_modules", "users", column: "created_by_id"
  add_foreign_key "quiz_responses", "questions", on_delete: :nullify
  add_foreign_key "quiz_responses", "quiz_attempts"
  add_foreign_key "study_module_assignments", "classrooms"
  add_foreign_key "study_module_assignments", "study_modules"
  add_foreign_key "study_modules", "quiz_modules", on_delete: :nullify
  add_foreign_key "study_modules", "users", column: "created_by_id"
  add_foreign_key "study_progresses", "users"
  add_foreign_key "teacher_access_requests", "users"
  add_foreign_key "teacher_access_requests", "users", column: "reviewed_by_id", on_delete: :nullify
  add_foreign_key "teacher_invitations", "users", column: "accepted_by_id", on_delete: :nullify
  add_foreign_key "teacher_invitations", "users", column: "invited_by_id"
end

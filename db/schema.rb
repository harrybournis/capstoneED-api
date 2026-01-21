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

ActiveRecord::Schema[8.1].define(version: 2017_06_18_163231) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_tokens", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.string "device"
    t.datetime "exp", precision: nil
    t.datetime "updated_at", precision: nil, null: false
    t.integer "user_id"
    t.index ["user_id"], name: "index_active_tokens_on_user_id"
  end

  create_table "assignments", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.datetime "end_date", precision: nil
    t.integer "lecturer_id"
    t.string "name"
    t.datetime "start_date", precision: nil
    t.integer "unit_id"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["lecturer_id"], name: "index_assignments_on_lecturer_id"
    t.index ["unit_id"], name: "index_assignments_on_unit_id"
  end

  create_table "deliverables", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.integer "end_offset"
    t.integer "iteration_id"
    t.jsonb "questions", default: {}, null: false
    t.integer "start_offset"
    t.string "type"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["iteration_id"], name: "index_deliverables_on_iteration_id"
    t.index ["questions"], name: "index_deliverables_on_questions", using: :gin
  end

  create_table "departments", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.string "name"
    t.string "university"
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "extensions", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.integer "deliverable_id"
    t.integer "extra_time"
    t.integer "project_id"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["deliverable_id"], name: "index_extensions_on_deliverable_id"
    t.index ["project_id"], name: "index_extensions_on_project_id"
  end

  create_table "feelings", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.string "css_class"
    t.string "name"
    t.datetime "updated_at", precision: nil, null: false
    t.integer "value"
  end

  create_table "feelings_project_evaluations", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.integer "feeling_id"
    t.integer "percent"
    t.integer "project_evaluation_id"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["feeling_id"], name: "index_feelings_project_evaluations_on_feeling_id"
    t.index ["project_evaluation_id"], name: "index_feelings_project_evaluations_on_project_evaluation_id"
  end

  create_table "form_templates", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.integer "lecturer_id"
    t.string "name"
    t.jsonb "questions"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["lecturer_id"], name: "index_form_templates_on_lecturer_id"
  end

  create_table "game_settings", id: :serial, force: :cascade do |t|
    t.integer "assignment_id"
    t.integer "marking_algorithm_id"
    t.integer "max_logs_per_day"
    t.integer "points_log"
    t.integer "points_log_first_of_day"
    t.integer "points_peer_assessment"
    t.integer "points_peer_assessment_first_of_team"
    t.integer "points_peer_assessment_submitted_first_day"
    t.integer "points_project_evaluation"
    t.integer "points_project_evaluation_first_of_team"
    t.integer "points_project_evaluation_submitted_first_day"
    t.index ["assignment_id"], name: "index_game_settings_on_assignment_id"
  end

  create_table "iteration_marks", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.integer "iteration_id"
    t.integer "mark"
    t.decimal "pa_score"
    t.integer "student_id"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["iteration_id"], name: "index_iteration_marks_on_iteration_id"
    t.index ["student_id"], name: "index_iteration_marks_on_student_id"
  end

  create_table "iterations", id: :serial, force: :cascade do |t|
    t.integer "assignment_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "deadline", precision: nil
    t.boolean "is_marked", default: false
    t.boolean "is_scored", default: false
    t.string "name"
    t.datetime "start_date", precision: nil
    t.datetime "updated_at", precision: nil, null: false
    t.index ["assignment_id"], name: "index_iterations_on_assignment_id"
  end

  create_table "log_points", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.datetime "date", precision: nil
    t.integer "log_id"
    t.integer "points"
    t.integer "project_id"
    t.integer "reason_id"
    t.integer "student_id"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["log_id"], name: "index_log_points_on_log_id"
    t.index ["project_id"], name: "index_log_points_on_project_id"
    t.index ["reason_id"], name: "index_log_points_on_reason_id"
  end

  create_table "peer_assessment_points", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.datetime "date", precision: nil
    t.integer "peer_assessment_id"
    t.integer "points"
    t.integer "project_id"
    t.integer "reason_id"
    t.integer "student_id"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["peer_assessment_id"], name: "index_peer_assessment_points_on_peer_assessment_id"
    t.index ["project_id"], name: "index_peer_assessment_points_on_project_id"
    t.index ["reason_id"], name: "index_peer_assessment_points_on_reason_id"
    t.index ["student_id"], name: "index_peer_assessment_points_on_student_id"
  end

  create_table "peer_assessments", id: :serial, force: :cascade do |t|
    t.jsonb "answers"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "date_submitted", precision: nil
    t.integer "pa_form_id"
    t.integer "project_id"
    t.integer "submitted_by_id"
    t.integer "submitted_for_id"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["pa_form_id"], name: "index_peer_assessments_on_pa_form_id"
    t.index ["project_id"], name: "index_peer_assessments_on_project_id"
    t.index ["submitted_by_id"], name: "index_peer_assessments_on_submitted_by_id"
    t.index ["submitted_for_id"], name: "index_peer_assessments_on_submitted_for_id"
  end

  create_table "project_evaluation_points", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.datetime "date", precision: nil
    t.integer "points"
    t.integer "project_evaluation_id"
    t.integer "project_id"
    t.integer "reason_id"
    t.integer "student_id"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["project_evaluation_id"], name: "index_project_evaluation_points_on_project_evaluation_id"
    t.index ["project_id"], name: "index_project_evaluation_points_on_project_id"
    t.index ["reason_id"], name: "index_project_evaluation_points_on_reason_id"
    t.index ["student_id"], name: "index_project_evaluation_points_on_student_id"
  end

  create_table "project_evaluations", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.datetime "date_submitted", precision: nil
    t.decimal "feelings_average"
    t.integer "iteration_id"
    t.integer "percent_complete"
    t.integer "project_id"
    t.datetime "updated_at", precision: nil, null: false
    t.integer "user_id"
    t.index ["iteration_id"], name: "index_project_evaluations_on_iteration_id"
    t.index ["project_id"], name: "index_project_evaluations_on_project_id"
    t.index ["user_id"], name: "index_project_evaluations_on_user_id"
  end

  create_table "projects", id: :serial, force: :cascade do |t|
    t.integer "assignment_id"
    t.string "color"
    t.datetime "created_at", precision: nil, null: false
    t.string "description"
    t.string "enrollment_key"
    t.string "logo"
    t.string "project_name"
    t.integer "rank"
    t.string "team_name"
    t.integer "unit_id"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["assignment_id"], name: "index_projects_on_assignment_id"
    t.index ["unit_id"], name: "index_projects_on_unit_id"
  end

  create_table "question_types", id: :serial, force: :cascade do |t|
    t.string "category"
    t.datetime "created_at", precision: nil, null: false
    t.string "friendly_name"
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "questions", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.integer "lecturer_id"
    t.integer "question_type_id"
    t.text "text"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["lecturer_id"], name: "index_questions_on_lecturer_id"
    t.index ["question_type_id"], name: "index_questions_on_question_type_id"
  end

  create_table "student_profiles", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.integer "level", default: 1
    t.integer "student_id"
    t.integer "total_xp", default: 0
    t.datetime "updated_at", precision: nil, null: false
    t.index ["student_id"], name: "index_student_profiles_on_student_id"
  end

  create_table "students_projects", id: :serial, force: :cascade do |t|
    t.jsonb "logs", default: [], null: false
    t.string "nickname"
    t.integer "points", default: 0
    t.integer "project_id"
    t.integer "student_id"
    t.index ["logs"], name: "index_students_projects_on_logs", using: :gin
    t.index ["project_id"], name: "index_students_projects_on_project_id"
    t.index ["student_id"], name: "index_students_projects_on_student_id"
  end

  create_table "units", id: :serial, force: :cascade do |t|
    t.date "archived_at"
    t.string "code"
    t.datetime "created_at", precision: nil, null: false
    t.integer "department_id"
    t.integer "lecturer_id"
    t.string "name"
    t.string "semester"
    t.datetime "updated_at", precision: nil, null: false
    t.integer "year"
    t.index ["department_id"], name: "index_units_on_department_id"
    t.index ["lecturer_id"], name: "index_units_on_lecturer_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "avatar_url"
    t.datetime "confirmation_sent_at", precision: nil
    t.string "confirmation_token"
    t.datetime "confirmed_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.inet "current_sign_in_ip"
    t.string "email", null: false
    t.string "encrypted_password"
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.datetime "last_sign_in_at", precision: nil
    t.inet "last_sign_in_ip"
    t.string "position"
    t.string "provider", default: "email", null: false
    t.datetime "reset_password_sent_at", precision: nil
    t.string "reset_password_token"
    t.integer "sign_in_count", default: 0, null: false
    t.string "type"
    t.string "unconfirmed_email"
    t.string "university"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "assignments", "units"
  add_foreign_key "projects", "assignments"
end

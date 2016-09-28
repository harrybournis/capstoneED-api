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

ActiveRecord::Schema.define(version: 20160924130730) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_tokens", force: :cascade do |t|
    t.datetime "exp"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "user_id"
    t.string   "device"
    t.index ["user_id"], name: "index_active_tokens_on_user_id", using: :btree
  end

  create_table "departments", force: :cascade do |t|
    t.string   "name"
    t.string   "university"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "iterations", force: :cascade do |t|
    t.string   "name"
    t.datetime "start_date"
    t.datetime "deadline"
    t.integer  "project_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_iterations_on_project_id", using: :btree
  end

  create_table "pa_forms", force: :cascade do |t|
    t.jsonb    "questions",    default: {}, null: false
    t.integer  "iteration_id"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.index ["iteration_id"], name: "index_pa_forms_on_iteration_id", using: :btree
    t.index ["questions"], name: "index_pa_forms_on_questions", using: :gin
  end

  create_table "peer_assessments", force: :cascade do |t|
    t.integer  "pa_form_id"
    t.integer  "submitted_by_id"
    t.integer  "submitted_for_id"
    t.datetime "date_submitted"
    t.jsonb    "answers"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.index ["pa_form_id"], name: "index_peer_assessments_on_pa_form_id", using: :btree
    t.index ["submitted_by_id"], name: "index_peer_assessments_on_submitted_by_id", using: :btree
    t.index ["submitted_for_id"], name: "index_peer_assessments_on_submitted_for_id", using: :btree
  end

  create_table "projects", force: :cascade do |t|
    t.date     "start_date"
    t.date     "end_date"
    t.text     "description"
    t.integer  "unit_id"
    t.integer  "lecturer_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["lecturer_id"], name: "index_projects_on_lecturer_id", using: :btree
    t.index ["unit_id"], name: "index_projects_on_unit_id", using: :btree
  end

  create_table "questions", force: :cascade do |t|
    t.text     "text"
    t.integer  "lecturer_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "category"
    t.index ["lecturer_id"], name: "index_questions_on_lecturer_id", using: :btree
  end

  create_table "students_teams", id: false, force: :cascade do |t|
    t.integer "student_id", null: false
    t.integer "team_id",    null: false
    t.index ["student_id"], name: "index_students_teams_on_student_id", using: :btree
    t.index ["team_id"], name: "index_students_teams_on_team_id", using: :btree
  end

  create_table "teams", force: :cascade do |t|
    t.string   "name"
    t.string   "logo"
    t.string   "enrollment_key"
    t.integer  "project_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.index ["project_id"], name: "index_teams_on_project_id", using: :btree
  end

  create_table "units", force: :cascade do |t|
    t.string   "name"
    t.string   "code"
    t.string   "semester"
    t.integer  "year"
    t.date     "archived_at"
    t.integer  "department_id"
    t.integer  "lecturer_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.index ["department_id"], name: "index_units_on_department_id", using: :btree
    t.index ["lecturer_id"], name: "index_units_on_lecturer_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "first_name",                               null: false
    t.string   "last_name",                                null: false
    t.string   "email",                                    null: false
    t.string   "type"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.string   "provider",               default: "email", null: false
    t.string   "encrypted_password"
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.integer  "sign_in_count",          default: 0,       null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.string   "position"
    t.string   "university"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

  add_foreign_key "projects", "units"
  add_foreign_key "teams", "projects"
end

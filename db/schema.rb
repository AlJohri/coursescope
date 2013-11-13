# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20131113035821) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "careers", force: true do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "careers_courses", force: true do |t|
    t.integer "career_id"
    t.integer "course_id"
  end

  add_index "careers_courses", ["career_id"], name: "index_careers_courses_on_career_id", using: :btree
  add_index "careers_courses", ["course_id"], name: "index_careers_courses_on_course_id", using: :btree

  create_table "classrooms", force: true do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "classrooms_courses", force: true do |t|
    t.integer "classroom_id"
    t.integer "course_id"
  end

  add_index "classrooms_courses", ["classroom_id"], name: "index_classrooms_courses_on_classroom_id", using: :btree
  add_index "classrooms_courses", ["course_id"], name: "index_classrooms_courses_on_course_id", using: :btree

  create_table "courses", id: false, force: true do |t|
    t.integer  "id",            null: false
    t.string   "title"
    t.integer  "number"
    t.integer  "section"
    t.datetime "start"
    t.datetime "end"
    t.integer  "days"
    t.string   "status"
    t.string   "type"
    t.integer  "term_id"
    t.integer  "department_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "courses", ["department_id"], name: "index_courses_on_department_id", using: :btree
  add_index "courses", ["term_id"], name: "index_courses_on_term_id", using: :btree

  create_table "courses_instructors", force: true do |t|
    t.integer "course_id"
    t.integer "instructor_id"
  end

  add_index "courses_instructors", ["course_id"], name: "index_courses_instructors_on_course_id", using: :btree
  add_index "courses_instructors", ["instructor_id"], name: "index_courses_instructors_on_instructor_id", using: :btree

  create_table "departments", force: true do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "instructors", force: true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "website"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "requirements", force: true do |t|
    t.integer  "course_id"
    t.integer  "prerequisite_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "requirements", ["course_id"], name: "index_requirements_on_course_id", using: :btree

  create_table "task_lists", force: true do |t|
    t.integer  "owner_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
  end

  add_index "task_lists", ["owner_id"], name: "index_task_lists_on_owner_id", using: :btree

  create_table "tasks", force: true do |t|
    t.string   "description",                 null: false
    t.integer  "priority"
    t.date     "due_date"
    t.boolean  "completed",   default: false, null: false
    t.integer  "list_id",                     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "terms", id: false, force: true do |t|
    t.integer  "id",         null: false
    t.string   "title"
    t.string   "year"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "authentication_token"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end

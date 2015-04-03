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

ActiveRecord::Schema.define(version: 20150403071512) do

  create_table "advertise_infos", force: :cascade do |t|
    t.integer  "event_id",     limit: 4
    t.string   "advertise_id", limit: 255
    t.string   "marketer_id",  limit: 255
    t.integer  "level",        limit: 4
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "call_requests", force: :cascade do |t|
    t.integer  "hospital_id",     limit: 4
    t.integer  "event_id",        limit: 4
    t.integer  "user_id",         limit: 4
    t.integer  "message_id",      limit: 4
    t.integer  "device",          limit: 4
    t.integer  "status",          limit: 4,     default: 0
    t.datetime "confirmed_at"
    t.integer  "old_id",          limit: 4
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.string   "name",            limit: 255
    t.string   "phone",           limit: 255
    t.text     "content",         limit: 65535
    t.boolean  "privacy_agree",   limit: 1
    t.string   "funnel",          limit: 255
    t.integer  "event_cost",      limit: 4
    t.string   "call_time",       limit: 255
    t.integer  "is_migration",    limit: 4
    t.integer  "age",             limit: 4
    t.integer  "sex",             limit: 4
    t.integer  "only_sms",        limit: 4,     default: 0
    t.integer  "old_hospital_id", limit: 4
  end

  add_index "call_requests", ["event_id"], name: "index_call_requests_on_event_id", using: :btree
  add_index "call_requests", ["hospital_id"], name: "index_call_requests_on_hospital_id", using: :btree
  add_index "call_requests", ["user_id"], name: "index_call_requests_on_user_id", using: :btree

  create_table "event_categories", force: :cascade do |t|
    t.string   "title",      limit: 255
    t.integer  "sort",       limit: 4
    t.boolean  "is_visible", limit: 1
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "parent_id",  limit: 4
  end

  create_table "event_event_categories", force: :cascade do |t|
    t.integer  "event_id",          limit: 4
    t.integer  "event_category_id", limit: 4
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "event_event_categories", ["event_category_id"], name: "index_event_event_categories_on_event_category_id", using: :btree
  add_index "event_event_categories", ["event_id"], name: "index_event_event_categories_on_event_id", using: :btree

  create_table "event_infos", force: :cascade do |t|
    t.integer  "event_id",          limit: 4
    t.text     "desc",              limit: 65535
    t.string   "title",             limit: 255
    t.string   "image",             limit: 255
    t.integer  "sort",              limit: 4
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.integer  "is_admin_info",     limit: 4,     default: 0
    t.integer  "is_client_info",    limit: 4,     default: 1
    t.string   "client_image",      limit: 255
    t.integer  "client_is_destroy", limit: 4,     default: 0
  end

  add_index "event_infos", ["event_id"], name: "index_event_infos_on_event_id", using: :btree

  create_table "events", force: :cascade do |t|
    t.boolean  "searchable",                           limit: 1,     default: false
    t.string   "hospital_type",                        limit: 255
    t.string   "title",                                limit: 255
    t.boolean  "is_temporary",                         limit: 1,     default: true
    t.date     "start_on"
    t.date     "end_on"
    t.string   "image",                                limit: 255
    t.string   "header",                               limit: 255
    t.text     "desc",                                 limit: 65535
    t.boolean  "is_numerical_original_price",          limit: 1,     default: false
    t.boolean  "is_numerical_discounted_price",        limit: 1,     default: false
    t.integer  "numerical_original_price",             limit: 4
    t.integer  "numerical_discounted_price",           limit: 4
    t.string   "original_price",                       limit: 255
    t.string   "discounted_price",                     limit: 255
    t.integer  "view_count",                           limit: 4,     default: 0
    t.integer  "call_requests_count",                  limit: 4,     default: 0
    t.integer  "fake_view_count",                      limit: 4,     default: 0
    t.integer  "fake_call_requests_count",             limit: 4,     default: 0
    t.integer  "old_id",                               limit: 4
    t.integer  "hospital_id",                          limit: 4
    t.datetime "created_at",                                                         null: false
    t.datetime "updated_at",                                                         null: false
    t.integer  "rank_score",                           limit: 4,     default: 0
    t.integer  "random_rank_score",                    limit: 4,     default: 0
    t.boolean  "is_web_view",                          limit: 1,     default: false
    t.string   "web_view_url",                         limit: 255
    t.boolean  "is_real_web_view",                     limit: 1
    t.string   "square_image",                         limit: 255
    t.integer  "apply_image_count",                    limit: 4,     default: 0
    t.integer  "is_migration",                         limit: 4
    t.integer  "event_status",                         limit: 4,     default: 1
    t.string   "deny_message",                         limit: 45
    t.boolean  "client_searchable",                    limit: 1
    t.string   "client_title",                         limit: 255
    t.boolean  "client_is_temporary",                  limit: 1
    t.date     "client_start_on"
    t.date     "client_end_on"
    t.string   "client_image",                         limit: 255
    t.string   "client_header",                        limit: 255
    t.text     "client_desc",                          limit: 65535
    t.boolean  "client_is_numerical_original_price",   limit: 1
    t.boolean  "client_is_numerical_discounted_price", limit: 1
    t.integer  "client_numerical_original_price",      limit: 4
    t.integer  "client_numerical_discounted_price",    limit: 4
    t.string   "client_original_price",                limit: 255
    t.string   "client_discounted_price",              limit: 255
    t.boolean  "client_is_web_view",                   limit: 1
    t.string   "client_web_view_url",                  limit: 255
    t.boolean  "client_is_real_web_view",              limit: 1
    t.string   "client_square_image",                  limit: 255
    t.integer  "event_cost",                           limit: 4
    t.integer  "old_hospital_id",                      limit: 4
    t.integer  "event_type",                           limit: 4,     default: 1
    t.string   "apply_text",                           limit: 255
    t.text     "promotion_url",                        limit: 65535
  end

  add_index "events", ["hospital_id"], name: "index_events_on_hospital_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "username",                        limit: 255
    t.string   "email",                           limit: 255
    t.string   "crypted_password",                limit: 255
    t.string   "salt",                            limit: 255
    t.integer  "user_type",                       limit: 4
    t.string   "picture",                         limit: 255
    t.integer  "call_requests_count",             limit: 4,   default: 0
    t.integer  "conversations_count",             limit: 4,   default: 0
    t.integer  "bookings_count",                  limit: 4,   default: 0
    t.integer  "user_know_hospitals_count",       limit: 4,   default: 0
    t.integer  "user_visit_hospitals_count",      limit: 4,   default: 0
    t.integer  "age",                             limit: 4
    t.integer  "sex",                             limit: 4
    t.integer  "job",                             limit: 4
    t.integer  "health_point",                    limit: 4,   default: 0
    t.datetime "created_at",                                                  null: false
    t.datetime "updated_at",                                                  null: false
    t.string   "remember_me_token",               limit: 255
    t.datetime "remember_me_token_expires_at"
    t.string   "reset_password_token",            limit: 255
    t.datetime "reset_password_token_expires_at"
    t.datetime "reset_password_email_sent_at"
    t.datetime "last_login_at"
    t.datetime "last_logout_at"
    t.datetime "last_activity_at"
    t.string   "access_token",                    limit: 255
    t.string   "phone",                           limit: 255
    t.string   "note",                            limit: 255
    t.boolean  "phone_agree",                     limit: 1,   default: false
    t.boolean  "email_agree",                     limit: 1,   default: false
    t.date     "birth_date"
    t.string   "gender",                          limit: 255
    t.integer  "old_id",                          limit: 4
    t.integer  "partnership_requests_count",      limit: 4,   default: 0
  end

  add_index "users", ["last_logout_at", "last_activity_at"], name: "index_users_on_last_logout_at_and_last_activity_at", using: :btree
  add_index "users", ["old_id"], name: "index_users_on_old_id", using: :btree
  add_index "users", ["remember_me_token"], name: "index_users_on_remember_me_token", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", using: :btree

end

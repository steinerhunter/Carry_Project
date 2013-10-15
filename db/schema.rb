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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20131013212400) do

  create_table "accepted_requests", :force => true do |t|
    t.integer  "request_delivery_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "confirmed",           :default => false
    t.boolean  "complete",            :default => false
  end

  create_table "accepted_suggests", :force => true do |t|
    t.integer  "suggest_delivery_id"
    t.integer  "user_id"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.boolean  "confirmed",           :default => false
    t.boolean  "complete",            :default => false
  end

  add_index "accepted_suggests", ["suggest_delivery_id", "user_id"], :name => "index_accepted_suggests_on_suggest_delivery_id_and_user_id", :unique => true
  add_index "accepted_suggests", ["suggest_delivery_id"], :name => "index_accepted_suggests_on_suggest_delivery_id"
  add_index "accepted_suggests", ["user_id"], :name => "index_accepted_suggests_on_user_id"

  create_table "authentications", :force => true do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "uid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "verified"
    t.string   "image"
  end

  create_table "comments", :force => true do |t|
    t.text     "content"
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.integer  "user_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "comments", ["user_id", "created_at"], :name => "index_comments_on_user_id_and_created_at"

  create_table "conversations", :force => true do |t|
    t.string   "subject",    :default => ""
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  create_table "notifications", :force => true do |t|
    t.string   "type"
    t.text     "body"
    t.string   "subject",              :default => ""
    t.integer  "sender_id"
    t.string   "sender_type"
    t.integer  "conversation_id"
    t.boolean  "draft",                :default => false
    t.datetime "updated_at",                              :null => false
    t.datetime "created_at",                              :null => false
    t.integer  "notified_object_id"
    t.string   "notified_object_type"
    t.string   "notification_code"
    t.string   "attachment"
    t.boolean  "global",               :default => false
    t.datetime "expires"
  end

  add_index "notifications", ["conversation_id"], :name => "index_notifications_on_conversation_id"

  create_table "receipts", :force => true do |t|
    t.integer  "receiver_id"
    t.string   "receiver_type"
    t.integer  "notification_id",                                  :null => false
    t.boolean  "is_read",                       :default => false
    t.boolean  "trashed",                       :default => false
    t.boolean  "deleted",                       :default => false
    t.string   "mailbox_type",    :limit => 25
    t.datetime "created_at",                                       :null => false
    t.datetime "updated_at",                                       :null => false
  end

  add_index "receipts", ["notification_id"], :name => "index_receipts_on_notification_id"

  create_table "request_deliveries", :force => true do |t|
    t.string   "from"
    t.string   "to"
    t.datetime "when",             :limit => 255
    t.string   "more_details"
    t.integer  "user_id"
    t.datetime "created_at",                                          :null => false
    t.datetime "updated_at",                                          :null => false
    t.string   "what"
    t.string   "cost"
    t.string   "size"
    t.string   "sending_person"
    t.string   "receiving_person"
    t.string   "currency"
    t.string   "status",                          :default => "Open"
    t.boolean  "has_all_details",                 :default => false
  end

  add_index "request_deliveries", ["user_id", "created_at"], :name => "index_request_deliveries_on_user_id_and_created_at"

  create_table "request_payments", :force => true do |t|
    t.integer  "request_delivery_id"
    t.integer  "user_id"
    t.string   "payKey"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.string   "status"
  end

  add_index "request_payments", ["request_delivery_id", "user_id"], :name => "index_request_payments_on_request_delivery_id_and_user_id", :unique => true
  add_index "request_payments", ["request_delivery_id"], :name => "index_request_payments_on_request_delivery_id"
  add_index "request_payments", ["user_id"], :name => "index_request_payments_on_user_id"

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "suggest_deliveries", :force => true do |t|
    t.string   "from"
    t.string   "to"
    t.datetime "when",            :limit => 255
    t.string   "more_details"
    t.integer  "user_id"
    t.datetime "created_at",                                         :null => false
    t.datetime "updated_at",                                         :null => false
    t.string   "size"
    t.string   "cost"
    t.string   "currency"
    t.string   "status",                         :default => "Open"
    t.boolean  "has_all_details",                :default => false
  end

  add_index "suggest_deliveries", ["user_id", "created_at"], :name => "index_suggest_deliveries_on_user_id_and_created_at"

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
    t.string   "password_digest"
    t.string   "remember_token"
    t.boolean  "admin",                    :default => false
    t.string   "password_reset_token"
    t.datetime "password_reset_sent_at"
    t.string   "email_confirmation_token"
    t.boolean  "email_confirmed",          :default => false
    t.boolean  "only_facebook"
    t.string   "phone"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["remember_token"], :name => "index_users_on_remember_token"

end

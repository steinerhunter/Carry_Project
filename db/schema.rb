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

ActiveRecord::Schema.define(:version => 20130803211121) do

  create_table "accepted_requests", :force => true do |t|
    t.integer  "request_delivery_id"
    t.integer  "user_id"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  add_index "accepted_requests", ["request_delivery_id", "user_id"], :name => "index_accepted_requests_on_request_delivery_id_and_user_id", :unique => true
  add_index "accepted_requests", ["request_delivery_id"], :name => "index_accepted_requests_on_request_delivery_id"
  add_index "accepted_requests", ["user_id"], :name => "index_accepted_requests_on_user_id"

  create_table "accepted_suggests", :force => true do |t|
    t.integer  "suggest_delivery_id"
    t.integer  "user_id"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  add_index "accepted_suggests", ["suggest_delivery_id", "user_id"], :name => "index_accepted_suggests_on_suggest_delivery_id_and_user_id", :unique => true
  add_index "accepted_suggests", ["suggest_delivery_id"], :name => "index_accepted_suggests_on_suggest_delivery_id"
  add_index "accepted_suggests", ["user_id"], :name => "index_accepted_suggests_on_user_id"

  create_table "comments", :force => true do |t|
    t.text     "content"
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.integer  "user_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "comments", ["user_id", "created_at"], :name => "index_comments_on_user_id_and_created_at"

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
  end

  add_index "request_deliveries", ["user_id", "created_at"], :name => "index_request_deliveries_on_user_id_and_created_at"

  create_table "request_relationships", :force => true do |t|
    t.integer  "accepter_id"
    t.integer  "request_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "request_relationships", ["accepter_id", "request_id"], :name => "index_request_relationships_on_accepter_id_and_request_id", :unique => true
  add_index "request_relationships", ["accepter_id"], :name => "index_request_relationships_on_accepter_id"
  add_index "request_relationships", ["request_id"], :name => "index_request_relationships_on_request_id"

  create_table "suggest_deliveries", :force => true do |t|
    t.string   "from"
    t.string   "to"
    t.datetime "when",         :limit => 255
    t.string   "more_details"
    t.integer  "user_id"
    t.datetime "created_at",                                      :null => false
    t.datetime "updated_at",                                      :null => false
    t.string   "size"
    t.string   "cost"
    t.string   "currency"
    t.string   "status",                      :default => "Open"
  end

  add_index "suggest_deliveries", ["user_id", "created_at"], :name => "index_suggest_deliveries_on_user_id_and_created_at"

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.string   "password_digest"
    t.string   "remember_token"
    t.boolean  "admin",           :default => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["remember_token"], :name => "index_users_on_remember_token"

end

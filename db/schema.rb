# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090315030649) do

  create_table "archives", :force => true do |t|
    t.integer  "owner_id"
    t.string   "name",        :limit => 64
    t.string   "description", :limit => 1024
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "collections", :force => true do |t|
    t.integer  "archive_id"
    t.string   "tag_line",    :limit => 64
    t.string   "description", :limit => 1024
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "collections_images", :id => false, :force => true do |t|
    t.integer "collection_id"
    t.integer "image_id"
  end

  create_table "image_show_views", :force => true do |t|
    t.integer "image_id"
    t.integer "portfolio_collection_id"
    t.integer "show_variant_id"
    t.integer "thumbnail_variant_id"
    t.integer "show_seq"
  end

  create_table "image_variants", :force => true do |t|
    t.integer  "image_id"
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.boolean  "is_master",            :default => false
    t.boolean  "is_web_default",       :default => false
    t.boolean  "is_thumbnail",         :default => false
    t.boolean  "is_thumbnail_default", :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "images", :force => true do |t|
    t.integer "archive_id"
    t.integer "master_variant_id"
    t.integer "web_default_variant_id"
    t.integer "thumbnail_default_variant_id"
    t.string  "description",                  :limit => 1024
  end

  create_table "owners", :force => true do |t|
    t.integer "user_id"
  end

  create_table "portfolio_collections", :force => true do |t|
    t.integer "portfolio_id"
    t.integer "collection_id"
    t.integer "default_show_view_id"
    t.integer "show_seq"
  end

  create_table "portfolios", :force => true do |t|
    t.integer  "archive_id"
    t.string   "description",          :limit => 128
    t.integer  "default_show_view_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", :force => true do |t|
    t.string "name"
  end

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer "role_id"
    t.integer "user_id"
  end

  add_index "roles_users", ["role_id"], :name => "index_roles_users_on_role_id"
  add_index "roles_users", ["user_id"], :name => "index_roles_users_on_user_id"

  create_table "user_failures", :force => true do |t|
    t.string   "remote_ip"
    t.string   "http_user_agent"
    t.string   "failure_type"
    t.string   "username"
    t.integer  "count",           :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_failures", ["remote_ip"], :name => "index_user_failures_on_remote_ip"

  create_table "users", :force => true do |t|
    t.string   "first_name",                :limit => 32
    t.string   "middle_name",               :limit => 32
    t.string   "last_name",                 :limit => 256
    t.string   "address1",                  :limit => 256
    t.string   "address2",                  :limit => 256
    t.string   "city",                      :limit => 64
    t.string   "state",                     :limit => 32
    t.string   "country",                   :limit => 32
    t.string   "zip",                       :limit => 16
    t.integer  "age"
    t.string   "gender",                    :limit => 0
    t.string   "occupation",                :limit => 64
    t.string   "login"
    t.string   "email"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.string   "activation_code",           :limit => 40
    t.datetime "activated_at"
    t.string   "user_type"
    t.string   "password_reset_code",       :limit => 40
    t.boolean  "enabled",                                  :default => true
    t.string   "identity_url"
    t.integer  "invitation_id"
    t.integer  "invitation_limit"
    t.string   "name",                      :limit => 100
  end

end

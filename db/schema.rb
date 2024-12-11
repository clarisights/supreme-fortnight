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

ActiveRecord::Schema[8.0].define(version: 2024_12_10_115440) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "ad_accounts", force: :cascade do |t|
    t.string "name"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_ad_accounts_on_user_id"
  end

  create_table "ad_sets", force: :cascade do |t|
    t.string "name"
    t.string "optimization_goal"
    t.date "start_date"
    t.date "end_date"
    t.integer "daily_budget"
    t.integer "lifetime_budget"
    t.string "billing_event"
    t.string "bid_strategy"
    t.bigint "campaign_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["campaign_id"], name: "index_ad_sets_on_campaign_id"
  end

  create_table "ads", force: :cascade do |t|
    t.string "name"
    t.string "landing_pages"
    t.string "ad_type"
    t.string "ad_format"
    t.date "start_date"
    t.string "facebook_post"
    t.string "instagram_post"
    t.bigint "ad_set_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ad_set_id"], name: "index_ads_on_ad_set_id"
  end

  create_table "analytics_data", force: :cascade do |t|
    t.string "campaign_name"
    t.string "adset_name"
    t.string "ad_name"
    t.integer "revenue"
    t.date "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "campaigns", force: :cascade do |t|
    t.string "name"
    t.string "objective"
    t.date "start_date"
    t.date "end_date"
    t.integer "daily_budget"
    t.integer "lifetime_budget"
    t.string "buying_type"
    t.bigint "ad_account_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ad_account_id"], name: "index_campaigns_on_ad_account_id"
  end

  create_table "metrics", force: :cascade do |t|
    t.bigint "ad_id", null: false
    t.date "date"
    t.integer "impressions"
    t.integer "all_clicks"
    t.integer "clicks"
    t.integer "spend"
    t.float "all_ctr"
    t.float "ctr"
    t.float "cplc"
    t.float "cpc"
    t.integer "comments"
    t.integer "likes"
    t.integer "landing_page_views"
    t.integer "mobile_app_installs"
    t.integer "video_plays"
    t.integer "conversions"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ad_id"], name: "index_metrics_on_ad_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "ad_accounts", "users"
  add_foreign_key "ad_sets", "campaigns"
  add_foreign_key "ads", "ad_sets"
  add_foreign_key "campaigns", "ad_accounts"
  add_foreign_key "metrics", "ads"
end

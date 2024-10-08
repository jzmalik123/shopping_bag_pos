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

ActiveRecord::Schema[7.1].define(version: 2024_09_22_121525) do
  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.integer "resource_id"
    t.string "author_type"
    t.integer "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource"
  end

  create_table "admin_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "bag_categories", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "bag_sizes", force: :cascade do |t|
    t.string "size"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "bag_type_id"
  end

  create_table "bag_types", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "configurations", force: :cascade do |t|
    t.string "key"
    t.string "value"
  end

  create_table "customers", force: :cascade do |t|
    t.string "name"
    t.string "mobile_number"
    t.integer "balance"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "expenses", force: :cascade do |t|
    t.string "name"
    t.integer "amount"
    t.date "expense_date"
    t.integer "admin_user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["admin_user_id"], name: "index_expenses_on_admin_user_id"
  end

  create_table "order_items", force: :cascade do |t|
    t.integer "order_id"
    t.integer "bag_size_id"
    t.integer "rate"
    t.integer "weight"
    t.integer "quantity"
    t.integer "amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bag_size_id"], name: "index_order_items_on_bag_size_id"
    t.index ["order_id"], name: "index_order_items_on_order_id"
  end

  create_table "orders", force: :cascade do |t|
    t.integer "customer_id"
    t.integer "bag_category_id"
    t.string "payment_method"
    t.date "order_date"
    t.integer "total_amount"
    t.integer "received_amount"
    t.integer "total_weight"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "created_by_id"
    t.index ["bag_category_id"], name: "index_orders_on_bag_category_id"
    t.index ["customer_id"], name: "index_orders_on_customer_id"
  end

  create_table "payments", force: :cascade do |t|
    t.string "source_type"
    t.integer "source_id"
    t.date "payment_date"
    t.string "payment_method"
    t.string "payment_type"
    t.integer "amount"
    t.integer "previous_balance"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["source_type", "source_id"], name: "index_payments_on_source"
  end

  create_table "vendor_order_items", force: :cascade do |t|
    t.integer "vendor_order_id"
    t.string "item_name"
    t.integer "weight"
    t.integer "rate"
    t.integer "quantity"
    t.integer "amount"
    t.integer "total_weight"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["vendor_order_id"], name: "index_vendor_order_items_on_vendor_order_id"
  end

  create_table "vendor_orders", force: :cascade do |t|
    t.integer "vendor_id"
    t.date "order_date"
    t.integer "total_amount"
    t.integer "received_amount"
    t.string "payment_method"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["vendor_id"], name: "index_vendor_orders_on_vendor_id"
  end

  create_table "vendors", force: :cascade do |t|
    t.string "name"
    t.integer "balance"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "bag_sizes", "bag_types"
  add_foreign_key "expenses", "admin_users"
  add_foreign_key "order_items", "bag_sizes"
  add_foreign_key "order_items", "orders", on_delete: :cascade
  add_foreign_key "orders", "admin_users", column: "created_by_id"
  add_foreign_key "orders", "bag_categories"
  add_foreign_key "orders", "customers"
  add_foreign_key "vendor_order_items", "vendor_orders", on_delete: :cascade
  add_foreign_key "vendor_orders", "vendors"
end

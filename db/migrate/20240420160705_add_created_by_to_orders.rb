class AddCreatedByToOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :orders, :created_by_id, :bigint
    add_foreign_key :orders, :admin_users, column: :created_by_id
  end
end

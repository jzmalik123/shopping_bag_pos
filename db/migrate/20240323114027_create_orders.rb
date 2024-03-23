class CreateOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :orders do |t|
      t.references :customer, foreign_key: true, index: true
      t.references :bag_category, foreign_key: :true
      t.string :payment_method
      t.date :order_date
      t.integer :total_amount
      t.integer :received_amount
      t.integer :total_weight
      t.timestamps
    end
  end
end

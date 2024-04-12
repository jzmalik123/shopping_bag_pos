class CreateVendorOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :vendor_orders do |t|
      t.references :vendor, foreign_key: true, index: true
      t.date :order_date
      t.integer :total_amount
      t.integer :received_amount
      t.string :payment_method
      t.timestamps
    end
  end
end

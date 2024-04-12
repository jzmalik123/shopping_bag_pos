class CreateVendorOrderItems < ActiveRecord::Migration[7.1]
  def change
    create_table :vendor_order_items do |t|
      t.references :vendor_order, foreign_key: { on_delete: :cascade }, index: true
      t.string :item_name
      t.integer :weight
      t.integer :rate
      t.integer :quantity
      t.integer :amount
      t.integer :total_weight
      t.timestamps
    end
  end
end

class CreateOrderItems < ActiveRecord::Migration[7.1]
  def change
    create_table :order_items do |t|
      t.references :order, foreign_key: { on_delete: :cascade }, index: true
      t.references :bag_size, foreign_key: :true
      t.integer :rate
      t.integer :weight
      t.integer :quantity
      t.integer :amount
      t.timestamps
    end
  end
end

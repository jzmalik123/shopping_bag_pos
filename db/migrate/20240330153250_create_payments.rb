class CreatePayments < ActiveRecord::Migration[7.1]
  def change
    create_table :payments do |t|
      t.references :source, polymorphic: true
      t.date :payment_date
      t.string :payment_method
      t.string :payment_type
      t.integer :amount
      t.integer :previous_balance
      t.timestamps
    end
  end
end

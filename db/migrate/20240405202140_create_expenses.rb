class CreateExpenses < ActiveRecord::Migration[7.1]
  def change
    create_table :expenses do |t|
      t.string :name
      t.integer :amount
      t.date :expense_date
      t.references :admin_user, foreign_key: true, index: true
      t.timestamps
    end
  end
end

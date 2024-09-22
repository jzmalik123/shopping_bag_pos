class AddBagTypeToBagSizes < ActiveRecord::Migration[7.1]
  def change
    add_column :bag_sizes, :bag_type_id, :bigint
    add_foreign_key :bag_sizes, :bag_types, column: :bag_type_id
  end
end

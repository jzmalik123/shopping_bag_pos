class CreateBagSizes < ActiveRecord::Migration[7.1]
  def change
    create_table :bag_sizes do |t|
      t.string :size
      t.timestamps
    end
  end
end

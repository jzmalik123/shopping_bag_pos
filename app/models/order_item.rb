class OrderItem < ApplicationRecord
  belongs_to :order, dependent: :destroy
  belongs_to :bag_size

  scope :customer, lambda { |customer_id|
    OrderItem.includes(order: :customer).where(orders: { customers: {id: customer_id}})
  }

  scope :bag_type, lambda { |bag_type_id|
    OrderItem.includes(bag_size: :bag_type).where(bag_sizes: { bag_types: { id: bag_type_id }})
  }

  def self.ransackable_scopes(_auth_object = nil)
    [:customer, :bag_type]
  end

  def total_weight
    weight * quantity
  end

  def total_bags
    (total_weight.to_f / 20).to_f
  end

  def total_amount
    rate * total_weight
  end

end

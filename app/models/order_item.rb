class OrderItem < ApplicationRecord
  belongs_to :order, dependent: :destroy
  belongs_to :bag_size

  scope :customer, lambda { |customer_id|
    OrderItem.includes(order: :customer).where(orders: { customers: {id: customer_id}})
  }

  def self.ransackable_scopes(_auth_object = nil)
    [:customer]
  end
end

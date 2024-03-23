class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :bag_size
end

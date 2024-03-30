class OrderItem < ApplicationRecord
  belongs_to :order, dependent: :destroy
  belongs_to :bag_size
end

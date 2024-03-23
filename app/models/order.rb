class Order < ApplicationRecord
  extend Enumerize
  enumerize :payment_method, in: [:cash, :bank_alfalah, :bank_meezan]

  attr_accessor :previous_balance, :remaining_balance

  has_many :order_items
  belongs_to :customer
  belongs_to :bag_category

  accepts_nested_attributes_for :order_items

end

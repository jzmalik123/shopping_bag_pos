class VendorOrder < ApplicationRecord
  
  attr_accessor :previous_balance, :remaining_balance, :customer_name

  has_many :vendor_order_items
  belongs_to :vendor

  accepts_nested_attributes_for :vendor_order_items

  def total_bags
    vendor_order_items.sum(:quantity)
  end

  def total_amount
    vendor_order_items.sum(:amount).to_i
  end

  def total_weight
    vendor_order_items.sum(&:total_weight)
  end
end

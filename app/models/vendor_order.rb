class VendorOrder < ApplicationRecord
  
  attr_accessor :previous_balance, :remaining_balance, :customer_name

  has_many :vendor_order_items
  belongs_to :vendor

  accepts_nested_attributes_for :vendor_order_items

end

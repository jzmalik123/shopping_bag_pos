class VendorOrderItem < ApplicationRecord

  belongs_to :vendor_order

  scope :vendor, lambda { |vendor_id|
    VendorOrderItem.includes(vendor_order: :vendor).where(vendor_orders: { vendors: {id: vendor_id}})
  }

  def self.ransackable_scopes(_auth_object = nil)
    [:vendor]
  end

  def total_weight
    weight * quantity
  end

  def total_bags
    quantity
  end
end

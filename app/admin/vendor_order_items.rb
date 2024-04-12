ActiveAdmin.register VendorOrderItem do

  filter :vendor, as: :searchable_select, collection: Vendor.all
  filter :created_at

  index do
    column :item_name
    column "Vendor Name" do |order_item|
      order_item.vendor_order.vendor.name
    end
    column :created_at
    column "Order" do |order_item|
      link_to order_item.vendor_order.id, admin_vendor_order_path(order_item.vendor_order)
    end
    column :rate
    column :weight
    column :amount
  end
end

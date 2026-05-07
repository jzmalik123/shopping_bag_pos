ActiveAdmin.register VendorOrderItem do

  filter :vendor, as: :searchable_select, collection: Vendor.all
  filter :vendor_order_order_date, as: :date_range, label: "Order Date"
  filter :created_at

  controller do
    before_action :set_default_month_filter, only: :index

    def scoped_collection
      super.includes(vendor_order: :vendor)
    end

    private

    def set_default_month_filter
      params[:q] ||= {}
      return if params[:q][:vendor_order_order_date_gteq].present? || params[:q][:vendor_order_order_date_lteq].present?

      params[:q][:vendor_order_order_date_gteq] = Date.current.beginning_of_month.to_s
      params[:q][:vendor_order_order_date_lteq] = Date.current.end_of_month.to_s
    end
  end

  index do
    column :order_date do |order_item| order_item.vendor_order.order_date.strftime("%B %d, %Y") end
    column "Order" do |order_item|
      link_to order_item.vendor_order.id, admin_vendor_order_path(order_item.vendor_order)
    end
    column "Vendor Name" do |order_item|
      order_item.vendor_order.vendor.name
    end
    column :item_name
    column :rate
    column :quantity
    column :weight
    column :amount
  end

  csv do
    column :created_at
    column "Order" do |order_item|
      order_item.vendor_order_id
    end
    column "Vendor Name" do |order_item|
      order_item.vendor_order.vendor.name
    end
    column :item_name
    column :rate
    column :quantity
    column :weight
    column :amount
  end
end

ActiveAdmin.register OrderItem do

  filter :customer, as: :searchable_select, collection: Customer.all
  filter :bag_type, as: :searchable_select, collection: -> { BagType.all }
  filter :order_order_date, as: :date_range, label: "Order Date"
  filter :created_at

  controller do
    before_action :set_default_month_filter, only: :index

    def scoped_collection
      super.includes(order: :customer, :bag_size)
    end

    private

    def set_default_month_filter
      params[:q] ||= {}
      return if params[:q][:order_order_date_gteq].present? || params[:q][:order_order_date_lteq].present?

      params[:q][:order_order_date_gteq] = Date.current.beginning_of_month.to_s
      params[:q][:order_order_date_lteq] = Date.current.end_of_month.to_s
    end
  end

  index do
    column "Order" do |order_item|
      link_to order_item.order.id, admin_order_path(order_item.order)
    end
    column :order_date do |order_item| order_item.order.order_date.strftime("%B %d, %Y") end
    column "Customer Name" do |order_item|
      order_item.order.customer.name
    end
    column :bag_size do |order_item| order_item.bag_size.size end
    column :rate
    column :weight do |order_item| order_item.total_weight end
    column :quantity
    column :amount
  end

  csv do
    column :id
    column :order_date do |order_item| order_item.order.order_date end
    column :customer_name do |order_item| order_item.order.customer.name end
    column :bag_size do |order_item| order_item.bag_size.size end
    column :rate
    column :total_weight do |order_item| order_item.total_weight end
    column :quantity
    column :amount
  end
end

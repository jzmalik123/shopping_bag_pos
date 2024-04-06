ActiveAdmin.register OrderItem do
  index do
    column "Customer Name" do |order_item|
      order_item.order.customer.name
    end
    column :created_at
    column "Order" do |order_item|
      link_to order_item.order.id, admin_order_path(order_item.order)
    end
    column :rate
    column :weight
    column :amount
  end
end
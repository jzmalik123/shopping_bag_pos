ActiveAdmin.register OrderItem do

  filter :customer, as: :searchable_select, collection: Customer.all
  filter :created_at

  index do
    column "Order" do |order_item|
      link_to order_item.order.id, admin_order_path(order_item.order)
    end
    column :created_at
    column "Customer Name" do |order_item|
      order_item.order.customer.name
    end
    column :bag_size do |order_item| order_item.bag_size.size end
    column :rate
    column :weight
    column :quantity
    column :amount
  end
end

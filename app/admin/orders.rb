ActiveAdmin.register Order do

  permit_params :customer_id, :previous_balance, :bag_category_id, :order_date, :payment_method, :total_amount, :received_amount, :total_weight, :remaining_balance, order_items_attributes: [:id, :bag_size_id, :rate, :weight, :quantity, :amount, :_destroy]
  config.paginate = false

  controller do

    def create
      params.permit!
      @order = Order.new(params[:order])
      if @order.save
        @order.customer.update!(balance: params[:order][:remaining_balance]) if @order.customer_id != Customer::WALKIN_CUSTOMER_ID
        render pdf: "#{@order.id}",
                page_size: 'A4',
                template: "invoices/invoice",
                orientation: "Portrait",
                lowquality: true,
                zoom: 1,
                dpi: 100,
                locals: {
                  order: @order,
                  order_items: @order.order_items.group_by(&:bag_size_id),
                  previous_balance: params[:order][:previous_balance],
                  customer_name: @order.customer_id == Customer::WALKIN_CUSTOMER_ID ? params[:order][:customer_name] : @order.customer.name
                } and return
      else
        flash[:notice] = 'Order cant be saved. Try again'
      end
    end
    
    def update
      params.permit!
      @order = Order.find(params[:id])
      if @order.update(params[:order])
        @order.customer.update!(balance: params[:order][:remaining_balance]) if @order.customer_id != Customer::WALKIN_CUSTOMER_ID
        render pdf: "#{@order.id}",
                page_size: 'A4',
                template: "invoices/invoice",
                orientation: "Portrait",
                lowquality: true,
                zoom: 1,
                dpi: 75,
                locals: {
                  order: @order,
                  order_items: @order.order_items.group_by(&:bag_size_id),
                  previous_balance: params[:order][:previous_balance],
                  customer_name: @order.customer_id == Customer::WALKIN_CUSTOMER_ID ? params[:order][:customer_name] : @order.customer.name
                } and return
      else
        flash[:notice] = 'Order cant be saved. Try again'
      end
    end

    def destroy
      @order = Order.find(params[:id])
      @order.destroy
      @order.customer.update(balance: @order.customer.balance + @order.received_amount - @order.total_amount)
      flash[:notice] = 'Order is deleted'
      redirect_to(admin_orders_path) and return 
    end
  end

  show do
    attributes_table_for order do
      row("CUSTOMER") { link_to(order.customer.name, admin_customer_path(order.customer_id)) }
      row("BAG CATEGORY") { order.bag_category.name }
      row("PAYMENT METHOD") { order.payment_method }
      row("ORDER DATE") { order.order_date.strftime("%B %d, %Y") }
      row("TOTAL AMOUNT") { number_with_delimiter(order.total_amount) }
      row("RECEIVED AMOUNT") { number_with_delimiter(order.received_amount) }
      row("TOTAL WEIGHT") { order.total_weight }
    end

    panel "Order Items" do
      table_for order.order_items do
        column("Bag Size") { |item| item.bag_size.size }
        column("Rate") { |item| number_with_delimiter(item.rate) }
        column("Weight") { |item| item.weight }
        column("Quantity") { |item| item.quantity }
        column("Amount") { |item| number_with_delimiter(item.amount) }
      end
    end
    active_admin_comments_for(resource)
  end

  index do
    panel "Summary" do
      h3 "Total Weight: #{orders.sum(&:total_weight)} KG"
      h3 "Total Bags: #{orders.sum(&:total_bags)} KG"
      h3 "Total Amount: #{number_with_delimiter orders.sum(&:total_amount)} Rs"
    end
    column :id
    column :bag_category
    column :order_date
    column :customer
    column :created_by
    column :total_bags do |order| order.total_bags end
    column :total_weight
    column :total_amount
    column :received_amount
    column :remaining_balance do |order| order.total_amount - order.received_amount end
    column :payment_method
    actions
  end

  csv do
    column :id
    column :bag_category do |order| order.bag_category.name end
    column :order_date
    column :customer do |order| order.customer.name end
    column :total_bags do |order| order.total_bags end
    column :total_weight
    column :total_amount
    column :received_amount
    column :remaining_balance do |order| order.total_amount - order.received_amount end
    column :payment_method
  end

  form do |f|
    f.inputs 'Order Details' do
      f.input :created_by_id, as: :hidden, input_html: { value: current_admin_user.id }
      f.input :customer, as: :searchable_select, label: 'Customer Name', selected: f.object.new_record? ? Customer::WALKIN_CUSTOMER_ID : f.object.customer_id, include_blank: false
      f.input :customer_name, label: 'Walkin Customer Name' if f.object.new_record? || f.object.customer_id == Customer::WALKIN_CUSTOMER_ID
      f.input :previous_balance, input_html: { readonly: true, value: f.object.new_record? ? '' : f.object.customer.balance - (f.object.total_amount - f.object.received_amount) }
      f.input :bag_category, label: 'Category', selected: BagCategory::FOUJI_BAG_CATEGORY_ID, include_blank: false
      f.input :order_date, as: :datepicker,
                    input_html: { value: Date.today }
      f.input :payment_method, label: 'Payment Method', selected: 'cash', include_blank: false
    end

    f.inputs 'Order Items' do
      f.has_many :order_items, heading: true, allow_destroy: true, new_record: true do |a|
        a.input :bag_size, as: :select, collection: BagSize.sizes_options
        a.input :rate, label: "Rate (Rs)", input_html: { onkeyup: 'calculateAmount(this)', value: a.object.new_record? ? Configuration.default_sale_date : a.object.rate }
        a.input :weight, label: "Weight (KG)", input_html: { value: f.object.new_record? ? 20 : a.object.weight, onkeyup: 'calculateAmount(this)' }
        a.input :quantity, label: "Quantity", input_html: { onkeyup: 'calculateAmount(this)' }
        a.input :amount, label: "Amount (Rs)", input_html: { readonly: true }
      end
    end
    
    f.inputs 'Order Summary' do
      f.input :total_amount, input_html: { readonly: true }
      f.input :received_amount, input_html: { onkeyup: 'updateRemainingBalance(this)', required: '' }
      f.input :total_weight, input_html: { readonly: true }
      f.input :remaining_balance, input_html: { readonly: true }
      f.input :total_quantity, input_html: { readonly: true, value: f.object.new_record? ? '' : f.object.order_items.sum(&:total_weight) }, label: 'Total Bags'
    end

    f.actions
  end
end

ActiveAdmin.register VendorOrder do

  permit_params :id, :vendor_id, :previous_balance, :order_date, :payment_method, :total_amount, :received_amount, :total_weight, :remaining_balance, vendor_order_items_attributes: [:id, :rate, :weight, :quantity, :amount, :_destroy]

  controller do

    def create
      params.permit!
      @vendor_order = VendorOrder.new(params[:vendor_order])
      if @vendor_order.save
        @vendor_order.vendor.update!(balance: params[:vendor_order][:remaining_balance])
        flash[:success] = 'Vendor order was successfully created'
      else
        flash[:notice] = 'Order cant be saved. Try again'
      end
      redirect_to admin_vendor_orders_path and return
    end
    
    def update
      params.permit!
      @vendor_order = VendorOrder.find(params[:id])
      if @vendor_order.update(params[:vendor_order])
        @vendor_order.vendor.update!(balance: params[:vendor_order][:remaining_balance])
        flash[:success] = 'Vendor order was successfully created'
      else
        flash[:notice] = 'Order cant be saved. Try again'
      end
      redirect_to admin_vendor_orders_path and return
    end

    def destroy
      @vendor_order = VendorOrder.find(params[:id])
      @vendor_order.destroy
      @vendor_order.vendor.update(balance: @vendor_order.total_amount - @vendor_order.received_amount)
      flash[:notice] = 'Order is deleted'
      redirect_to(admin_vendor_orders_path) and return 
    end
  end

  show do
    attributes_table_for vendor_order do
      row("Vendor") { link_to(vendor_order.vendor.name, admin_vendor_path(vendor_order.vendor_id)) }
      row("PAYMENT METHOD") { vendor_order.payment_method }
      row("ORDER DATE") { vendor_order.order_date.strftime("%B %d, %Y") }
      row("TOTAL AMOUNT") { number_with_delimiter(vendor_order.total_amount) }
      row("RECEIVED AMOUNT") { number_with_delimiter(vendor_order.received_amount) }
      row("TOTAL WEIGHT") { vendor_order.vendor_order_items.sum(&:total_weight) }
      row("TOTAL BAGS") { vendor_order.vendor_order_items.sum(&:quantity) }
    end

    panel "Order Items" do
      table_for vendor_order.vendor_order_items do
        column("Name") { |item| item.item_name }
        column("Rate") { |item| number_with_delimiter(item.rate) }
        column("Weight") { |item| item.weight }
        column("Quantity") { |item| item.quantity }
        column("Total Weight") { |item| number_with_delimiter(item.total_weight) }
        column("Amount") { |item| number_with_delimiter(item.amount) }
      end
    end
    active_admin_comments_for(resource)
  end

  index do
    panel "Summary" do
      h3 "Total Weight: #{VendorOrderItem.where(vendor_order_id: vendor_orders.pluck(:id)).sum(&:total_weight)} KG"
      h3 "Total Bags: #{VendorOrderItem.where(vendor_order_id: vendor_orders.pluck(:id)).sum(&:quantity)}"
      h3 "Total Amount: #{number_with_delimiter vendor_orders.sum(&:total_amount)} Rs"
    end
    column :id
    column :vendor
    column :payment_method
    column :order_date
    column :total_amount
    column :paid_amount do |vendor_order| vendor_order.received_amount end
    column :total_bags do |vendor_order| vendor_order.vendor_order_items.sum(:quantity) end 
    actions
  end

  form do |f|
    f.inputs 'Order Details' do
      f.input :vendor, as: :searchable_select, label: 'Vendor Name'#, include_blank: false
      f.input :previous_balance, input_html: { readonly: true }
      f.input :order_date, as: :datepicker,
                    input_html: { value: Date.today },
                    datepicker_options: {
                      max_date: Date.today
                    }
      f.input :payment_method, label: 'Payment Method', selected: 'cash', include_blank: false
    end

    f.inputs 'Order Items' do
      f.has_many :vendor_order_items, heading: true, allow_destroy: true, new_record: true do |a|
        a.input :item_name, label: "Item Name"
        a.input :rate, label: "Unit Price (Rs)", input_html: { onkeyup: 'calculateAmount(this)' }
        a.input :weight, label: "Weight (KG)"
        a.input :quantity, label: "Quantity", input_html: { onkeyup: 'calculateAmount(this)' }
        a.input :amount, label: "Amount (Rs)", input_html: { readonly: true }
      end
    end
    
    f.inputs 'Order Summary' do
      f.input :total_amount, input_html: { readonly: true }
      f.input :received_amount, label: 'Paid Amount', input_html: { onkeyup: 'updateRemainingBalance(this)' }
      f.input :remaining_balance, input_html: { readonly: true }
    end

    f.actions
  end
end

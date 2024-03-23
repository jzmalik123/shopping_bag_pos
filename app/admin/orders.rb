ActiveAdmin.register Order do

  permit_params :customer_id, :previous_balance, :bag_category_id, :order_date, :payment_method, :total_amount, :received_amount, :total_weight, :remaining_balance, order_items_attributes: [:id, :bag_size_id, :rate, :weight, :quantity, :amount, :_destroy]

  controller do

    def create
      params.permit!
      @order = Order.new(params[:order])
      if @order.save
        @order.customer.update!(balance: params[:order][:remaining_balance])
        redirect_to admin_order_path(@order) and return
      else
        flash[:notice] = 'Order cant be saved. Try again'
      end
    end

  end


  form do |f|
    f.inputs 'Order Details' do
      f.input :customer, label: 'Customer Name', selected: Customer::WALKIN_CUSTOMER_ID, include_blank: false
      f.input :previous_balance, input_html: { readonly: true }
      f.input :bag_category, label: 'Category', selected: BagCategory::FOUJI_BAG_CATEGORY_ID, include_blank: false
      f.input :order_date, as: :datepicker,
                    input_html: { value: Date.today },
                    datepicker_options: {
                      max_date: Date.today
                    }
      f.input :payment_method, label: 'Payment Method', selected: 'cash', include_blank: false
    end

    f.inputs 'Order Items' do
      f.has_many :order_items, heading: true, allow_destroy: true, new_record: true do |a|
        a.input :bag_size, as: :select, collection: BagSize.sizes_options
        a.input :rate, label: "Rate (Rs)", input_html: { onkeyup: 'calculateAmount(this)' }
        a.input :weight, label: "Weight (KG)", input_html: { value: 20, onkeyup: 'calculateAmount(this)' }
        a.input :quantity, label: "Quantity", input_html: { onkeyup: 'calculateAmount(this)' }
        a.input :amount, label: "Amount (Rs)", input_html: { readonly: true }
      end
    end
    
    f.inputs 'Order Summary' do
      f.input :total_amount, input_html: { readonly: true }
      f.input :received_amount, input_html: { onkeyup: 'updateRemainingBalance(this)' }
      f.input :total_weight, input_html: { readonly: true }
      f.input :remaining_balance, input_html: { readonly: true }
    end

    f.actions
  end
end

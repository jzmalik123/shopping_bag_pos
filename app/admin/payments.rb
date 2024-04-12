ActiveAdmin.register Payment do

  #permit_params :customer_id, :previous_balance, :bag_category_id, :order_date, :payment_method, :total_amount, :received_amount, :total_weight, :remaining_balance, order_items_attributes: [:id, :bag_size_id, :rate, :weight, :quantity, :amount, :_destroy]

  controller do

    def create
      params.permit!
      @payment = Payment.new(params[:payment])
      if @payment.save
        payment_source = @payment.source
        if payment_source.is_a?(Customer)
          payment_source = @payment.source
          if @payment.payment_type.incoming?
            payment_source.update(balance: payment_source.balance - @payment.amount)
          else
            payment_source.update(balance: payment_source.balance + @payment.amount)
          end
          render pdf: "Invoice #{@payment.id}",
            page_size: 'A4',
            template: "invoices/payment_invoice",
            orientation: "Portrait",
            lowquality: true,
            zoom: 1,
            dpi: 75,
            locals: {
              payment: @payment
            } and return
        elsif payment_source.is_a?(Vendor)
          if @payment.payment_type.incoming?
            payment_source.update(balance: payment_source.balance + @payment.amount)
          else
            payment_source.update(balance: payment_source.balance - @payment.amount)
          end
        end
      else
        flash[:notice] = 'Payment cant be saved. Try again'
      end
      redirect_to(admin_payments_path) and return 
    end

    def permitted_params
      params.permit!
    end
    
  end

  form do |f|
    f.inputs 'Payment Details' do
      f.input :source, collection: grouped_options_for_select(
        {
          'Customers' => Customer.all.map{|customer| [ customer.name, customer.id, { data: { balance: customer.balance, source_type: 'Customer' } }] },
          'Vendors' => Vendor.all.map{|vendor| [vendor.name, vendor.id, { data: { balance: vendor.balance, source_type: 'Vendor' } }] }
        }, [f.object.source_id, f.object.source_type]
      ), label: 'Name'
      f.input :source_type, as: :hidden, value: f.object.new_record? ? '' : f.object.source.class.name
      f.input :payment_type, label: 'Payment Type', include_blank: false
      f.input :previous_balance, label: 'Previous Balance', input_html: { readonly: true }
      f.input :amount, label: 'Payment Amount'
      f.input :payment_date, as: :datepicker,
                    input_html: { value: Date.today },
                    datepicker_options: {
                      max_date: Date.today
                    }
      f.input :payment_method, label: 'Payment Method', selected: 'cash', include_blank: false
    end

    f.actions
  end
end

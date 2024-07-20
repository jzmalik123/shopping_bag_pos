ActiveAdmin.register Customer do

  permit_params :name, :mobile_number, :balance

  member_action :previous_balance, method: :get do
    render json: { balance: Customer.find(params[:id]).balance } and return
  end

  index do
    panel "Summary" do
      h3 "Total Balance: #{number_with_delimiter Customer.all.sum(&:balance) rescue 0} Rs"
    end
    column :id
    column :name
    column :balance
    actions
  end

  show do
    attributes_table do
      row :name
      row :mobile_number
      row :balance
      row :created_at do |customer|
        customer.created_at.strftime("%B %d, %Y %H:%M")
      end
      row :updated_at do |customer|
        customer.updated_at.strftime("%B %d, %Y %H:%M")
      end
    end

    panel "Payments" do
      table_for customer.payments do
        column "Payment Date", :payment_date do |payment|
          payment.payment_date.strftime("%B %d, %Y")
        end
        column "Payment Method", :payment_method
        column "Payment Type", :payment_type
        column "Amount", :amount do |payment|
          payment.amount
        end
        column "Previous Balance", :previous_balance do |payment|
          payment.previous_balance
        end
        column "Created At", :created_at do |payment|
          payment.created_at.strftime("%B %d, %Y %H:%M")
        end
        column "Updated At", :updated_at do |payment|
          payment.updated_at.strftime("%B %d, %Y %H:%M")
        end
      end
    end

  end

  csv do
    column :id
    column :name
    column :balance
    column :updated_at
  end
  #searchable_select_options(name: :all, scope: Customer.all.order('name ASC'), text_attribute: :name)
end

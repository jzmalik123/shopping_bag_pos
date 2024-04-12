ActiveAdmin.register Customer do

  permit_params :name, :mobile_number, :balance

  member_action :previous_balance, method: :get do
    render json: { balance: Customer.find(params[:id]).balance } and return
  end

  index do
    panel "Summary" do
      h3 "Total Balance: #{number_with_delimiter customers.sum(&:balance) rescue 0} Rs"
    end
    column :id
    column :name
    column :balance
    actions
  end

  csv do
    column :id
    column :name
    column :balance
    column :updated_at
  end
  #searchable_select_options(name: :all, scope: Customer.all.order('name ASC'), text_attribute: :name)
end

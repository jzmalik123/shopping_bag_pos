ActiveAdmin.register Customer do

  permit_params :name, :mobile_number, :balance

  member_action :previous_balance, method: :get do
    render json: { balance: Customer.find(params[:id]).balance } and return
  end

end

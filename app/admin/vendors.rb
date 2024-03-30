ActiveAdmin.register Vendor do

  permit_params :name, :balance

  member_action :previous_balance, method: :get do
    render json: { balance: Vendor.find(params[:id]).balance } and return
  end

end

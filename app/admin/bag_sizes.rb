ActiveAdmin.register BagSize do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :size, :bag_type, :bag_type_id
  #
  # or
  #
  # permit_params do
  #   permitted = [:name]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  
  form do |f|
    f.inputs 'Bag Size' do
      f.input :size, label: 'Size'
      f.input :bag_type, as: :select, label: 'Bag Type', include_blank: false
    end
    f.actions
  end
end

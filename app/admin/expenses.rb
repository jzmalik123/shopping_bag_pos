ActiveAdmin.register Expense do

  permit_params :name, :amount, :expense_date
  config.paginate = false

  form do |f|
    f.inputs 'Expense Details' do
      f.input :name
      f.input :amount
      f.input :expense_date, as: :datepicker,
                    input_html: { value: Date.today }
    end
    f.actions
  end

  index do
    panel "Summary" do
      h3 "Total Expenses: #{number_with_delimiter expenses.sum(&:amount) rescue 0} Rs"
    end
    column :id
    column :expense_date
    column :name
    column :amount
    column :updated_at
    actions
  end

  csv do
    column :id
    column :expense_date
    column :name
    column :amount
    column :updated_at
  end

  controller do
    def update
      super do |format|
        if resource.errors.empty?
          redirect_to admin_expenses_path, notice: "Expense was successfully updated." and return
        else
          render :edit and return
        end
      end
    end

    def create
      super do |format|
        if resource.errors.empty?
          redirect_to admin_expenses_path, notice: "Expense was successfully created." and return
        else
          render :new and return
        end
      end
    end
    
  end
end

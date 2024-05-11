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
  end

  csv do
    column :id
    column :expense_date
    column :name
    column :amount
    column :updated_at
  end
end

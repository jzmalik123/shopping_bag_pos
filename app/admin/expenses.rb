ActiveAdmin.register Expense do

  permit_params :name, :amount, :expense_date

  form do |f|
    f.inputs 'Expense Details' do
      f.input :name
      f.input :amount
      f.input :expense_date, as: :datepicker,
                    input_html: { value: Date.today },
                    datepicker_options: {
                      max_date: Date.today
                    }
    end
    f.actions
  end

  csv do
    column :id
    column :expense_date
    column :name
    column :amount
    column :updated_at
  end
end

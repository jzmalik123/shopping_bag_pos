ActiveAdmin.register Expense do

  permit_params :name, :amount, :expense_date
  config.paginate = true
  config.per_page = 50

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
    summary_expenses = Expense.ransack(params[:q]).result

    panel "Summary" do
      h3 "Total Expenses: #{number_with_delimiter(summary_expenses.sum(:amount))} Rs"
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
    before_action :set_default_month_filter, only: :index

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

    private

    def set_default_month_filter
      params[:q] ||= {}
      return if params[:q][:expense_date_gteq].present? || params[:q][:expense_date_lteq].present?

      start_of_month = Date.current.beginning_of_month
      end_of_month = Date.current.end_of_month
      params[:q][:expense_date_gteq] = start_of_month.to_s
      params[:q][:expense_date_lteq] = end_of_month.to_s
    end
  end
end

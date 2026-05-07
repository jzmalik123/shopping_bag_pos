ActiveAdmin.register_page "Customer Ledger" do
  menu priority: 12, label: "Customer Ledger"

  build_ledger_data = lambda do |params|
    parsed_start_date = Date.parse(params[:start_date]) rescue nil
    parsed_end_date = Date.parse(params[:end_date]) rescue nil
    start_date = parsed_start_date || Date.current.beginning_of_month
    end_date = parsed_end_date || Date.current.end_of_month
    end_date = start_date if end_date < start_date

    selected_customer_id = params[:customer_id].presence&.to_i
    selected_customer = selected_customer_id.present? ? Customer.find_by(id: selected_customer_id) : nil

    return {
      start_date: start_date,
      end_date: end_date,
      selected_customer_id: selected_customer_id,
      selected_customer: selected_customer,
      opening_balance: 0.0,
      ledger_rows: []
    } unless selected_customer

    orders_before = selected_customer.orders.where("order_date < ?", start_date)
    incoming_payments_before = selected_customer.payments.with_payment_type(:incoming).where("payment_date < ?", start_date)

    opening_balance = orders_before.sum("COALESCE(total_amount, 0) - COALESCE(received_amount, 0)").to_f
    opening_balance -= incoming_payments_before.sum(:amount).to_f

    ledger_rows = []

    selected_customer.orders.where(order_date: start_date..end_date).find_each do |order|
      ledger_rows << {
        date: order.order_date,
        type: "sale",
        id: order.id,
        kg: order.total_weight.to_f,
        amount: order.total_amount.to_f,
        amount_received: order.received_amount.to_f,
        balance_impact: order.total_amount.to_f - order.received_amount.to_f,
        sort_priority: 1
      }
    end

    selected_customer.payments.with_payment_type(:incoming).where(payment_date: start_date..end_date).find_each do |payment|
      ledger_rows << {
        date: payment.payment_date,
        type: "amount received",
        id: payment.id,
        kg: nil,
        amount: nil,
        amount_received: payment.amount.to_f,
        balance_impact: -payment.amount.to_f,
        sort_priority: 2
      }
    end

    ledger_rows.sort_by! { |row| [row[:date], row[:sort_priority], row[:id]] }

    running_balance = opening_balance
    ledger_rows.each do |row|
      running_balance += row[:balance_impact]
      row[:balance] = running_balance
    end

    {
      start_date: start_date,
      end_date: end_date,
      selected_customer_id: selected_customer_id,
      selected_customer: selected_customer,
      opening_balance: opening_balance,
      ledger_rows: ledger_rows
    }
  end

  action_item :export_pdf, only: :index do
    if params[:customer_id].present?
      link_to(
        "Export PDF",
        admin_customer_ledger_export_pdf_path(
          customer_id: params[:customer_id],
          start_date: params[:start_date],
          end_date: params[:end_date]
        )
      )
    end
  end

  page_action :export_pdf, method: :get do
    ledger_data = build_ledger_data.call(params)
    selected_customer = ledger_data[:selected_customer]

    unless selected_customer
      redirect_to admin_customer_ledger_path, alert: "Please select a customer first." and return
    end

    render pdf: "Customer Ledger #{selected_customer.name} #{ledger_data[:start_date]} to #{ledger_data[:end_date]}",
           page_size: "A4",
           template: "invoices/customer_ledger",
           orientation: "Landscape",
           lowquality: true,
           zoom: 1,
           dpi: 100,
           locals: {
             ledger_data: ledger_data
           }
  end

  content title: "Customer Ledger" do
    ledger_data = build_ledger_data.call(params)
    start_date = ledger_data[:start_date]
    end_date = ledger_data[:end_date]
    selected_customer_id = ledger_data[:selected_customer_id]
    selected_customer = ledger_data[:selected_customer]

    panel "Filters" do
      div do
        form action: admin_customer_ledger_path, method: :get do
          div style: "display:flex;gap:12px;align-items:flex-end;flex-wrap:wrap;" do
            div do
              label "Customer"
              select name: "customer_id" do
                option value: "" do
                  text_node "Select Customer"
                end
                Customer.order(:name).pluck(:name, :id).each do |name, id|
                  option value: id, selected: (id == selected_customer_id) do
                    text_node name
                  end
                end
              end
            end
            div do
              label "Start Date"
              input type: "date", name: "start_date", value: start_date.to_s
            end
            div do
              label "End Date"
              input type: "date", name: "end_date", value: end_date.to_s
            end
            div do
              input type: "submit", value: "Apply", class: "button"
            end
          end
        end
      end
    end

    unless selected_customer
      panel "Ledger" do
        div "Please select a customer to view ledger."
      end
      next
    end

    opening_balance = ledger_data[:opening_balance]
    ledger_rows = ledger_data[:ledger_rows]

    panel "Ledger for #{selected_customer.name} (#{start_date.strftime('%d %b %Y')} - #{end_date.strftime('%d %b %Y')})" do
      div style: "margin-bottom:10px;font-weight:600;" do
        text_node "Opening Balance: #{number_with_delimiter(opening_balance.round(2))}"
      end

      table style: "width:100%;border-collapse:collapse;background:#fff;" do
        thead do
          tr style: "background:#f6f7fb;" do
            th "Date", style: "text-align:left;padding:10px;border:1px solid #e5e7eb;"
            th "Type", style: "text-align:left;padding:10px;border:1px solid #e5e7eb;"
            th "ID", style: "text-align:right;padding:10px;border:1px solid #e5e7eb;"
            th "KG", style: "text-align:right;padding:10px;border:1px solid #e5e7eb;"
            th "Amount", style: "text-align:right;padding:10px;border:1px solid #e5e7eb;"
            th "Amount Received", style: "text-align:right;padding:10px;border:1px solid #e5e7eb;"
            th "Balance", style: "text-align:right;padding:10px;border:1px solid #e5e7eb;"
          end
        end
        tbody do
          if ledger_rows.empty?
            tr do
              td "No transactions found for selected range.", colspan: 7, style: "padding:12px;border:1px solid #e5e7eb;text-align:center;color:#64748b;"
            end
          else
            ledger_rows.each do |row|
              tr do
                td row[:date].strftime("%d-%b"), style: "padding:10px;border:1px solid #e5e7eb;"
                td row[:type], style: "padding:10px;border:1px solid #e5e7eb;"
                td number_with_delimiter(row[:id]), style: "text-align:right;padding:10px;border:1px solid #e5e7eb;"
                td(row[:kg].present? ? number_with_delimiter(row[:kg].round(2)) : "", style: "text-align:right;padding:10px;border:1px solid #e5e7eb;")
                td(row[:amount].present? ? number_with_delimiter(row[:amount].round(2)) : "", style: "text-align:right;padding:10px;border:1px solid #e5e7eb;")
                td number_with_delimiter(row[:amount_received].to_f.round(2)), style: "text-align:right;padding:10px;border:1px solid #e5e7eb;"
                td number_with_delimiter(row[:balance].round(2)), style: "text-align:right;padding:10px;border:1px solid #e5e7eb;font-weight:600;"
              end
            end
          end
        end
      end
    end
  end
end

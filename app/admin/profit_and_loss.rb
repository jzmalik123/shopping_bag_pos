ActiveAdmin.register_page "Profit And Loss" do
  menu priority: 11, label: "Profit & Loss"

  content title: "Profit & Loss Statement" do
    selected_month = params[:month].presence || Date.current.strftime("%Y-%m")
    selected_date = Date.strptime("#{selected_month}-01", "%Y-%m-%d") rescue Date.current
    start_date = selected_date.beginning_of_month
    end_date = selected_date.end_of_month

    orders = Order.where(order_date: start_date..end_date)
    vendor_orders = VendorOrder.where(order_date: start_date..end_date).includes(:vendor_order_items)
    expenses = Expense.where(expense_date: start_date..end_date)

    total_kgs_sold = orders.sum(:total_weight).to_f
    total_sales_value = orders.sum(:total_amount).to_f

    total_kgs_purchased = vendor_orders.sum { |vendor_order| vendor_order.vendor_order_items.sum(&:total_weight).to_f }
    total_purchase_value = vendor_orders.sum { |vendor_order| vendor_order.vendor_order_items.sum(&:amount).to_f }

    total_expenses = expenses.sum(:amount).to_f
    final_kg_balance = total_kgs_sold - total_kgs_purchased
    final_value_balance = total_sales_value - total_purchase_value - total_expenses

    chart_total = total_sales_value + total_purchase_value + total_expenses
    sales_pct = chart_total.positive? ? ((total_sales_value / chart_total) * 100.0) : 0
    purchases_pct = chart_total.positive? ? ((total_purchase_value / chart_total) * 100.0) : 0
    expenses_pct = chart_total.positive? ? ((total_expenses / chart_total) * 100.0) : 0

    panel "Filters" do
      div do
        form action: admin_profit_and_loss_path, method: :get do
          div style: "display:flex;gap:12px;align-items:flex-end;flex-wrap:wrap;" do
            div do
              label "Month & Year"
              input type: "month", name: "month", value: selected_month
            end
            div do
              input type: "submit", value: "Apply", class: "button"
            end
          end
        end
      end
    end

    panel "Statement for #{start_date.strftime('%B %Y')}" do
      div style: "display:flex;gap:24px;flex-wrap:wrap;align-items:flex-start;" do
        div style: "flex:2;min-width:460px;" do
          table style: "width:100%;border-collapse:collapse;background:#fff;" do
            thead do
              tr style: "background:#f6f7fb;" do
                th "Metric", style: "text-align:left;padding:10px;border:1px solid #e5e7eb;"
                th "KG", style: "text-align:right;padding:10px;border:1px solid #e5e7eb;"
                th "Value (Rs)", style: "text-align:right;padding:10px;border:1px solid #e5e7eb;"
              end
            end
            tbody do
              tr do
                td "Sales (Orders)", style: "padding:10px;border:1px solid #e5e7eb;"
                td number_with_delimiter(total_kgs_sold.round(2)), style: "text-align:right;padding:10px;border:1px solid #e5e7eb;"
                td number_with_delimiter(total_sales_value.round(2)), style: "text-align:right;padding:10px;border:1px solid #e5e7eb;"
              end
              tr do
                td "Purchases (Vendor Orders)", style: "padding:10px;border:1px solid #e5e7eb;"
                td number_with_delimiter(total_kgs_purchased.round(2)), style: "text-align:right;padding:10px;border:1px solid #e5e7eb;"
                td number_with_delimiter(total_purchase_value.round(2)), style: "text-align:right;padding:10px;border:1px solid #e5e7eb;"
              end
              tr do
                td "Expenses", style: "padding:10px;border:1px solid #e5e7eb;"
                td "-", style: "text-align:right;padding:10px;border:1px solid #e5e7eb;"
                td number_with_delimiter(total_expenses.round(2)), style: "text-align:right;padding:10px;border:1px solid #e5e7eb;"
              end
              tr style: "background:#eef6ff;font-weight:700;" do
                td "Final KG Balance", style: "padding:10px;border:1px solid #e5e7eb;"
                td number_with_delimiter(final_kg_balance.round(2)), style: "text-align:right;padding:10px;border:1px solid #e5e7eb;"
                td "-", style: "text-align:right;padding:10px;border:1px solid #e5e7eb;"
              end
              tr style: "background:#e7fff1;font-weight:700;" do
                td "Final Value Balance", style: "padding:10px;border:1px solid #e5e7eb;"
                td "-", style: "text-align:right;padding:10px;border:1px solid #e5e7eb;"
                td number_with_delimiter(final_value_balance.round(2)), style: "text-align:right;padding:10px;border:1px solid #e5e7eb;"
              end
            end
          end
        end

        div style: "flex:1;min-width:240px;" do
          div style: "font-weight:600;margin-bottom:10px;" do
            text_node "Value Distribution Pie Chart"
          end
          div style: "width:220px;height:220px;border-radius:50%;background:conic-gradient(#22c55e 0 #{sales_pct.round(2)}%, #3b82f6 #{sales_pct.round(2)}% #{(sales_pct + purchases_pct).round(2)}%, #f97316 #{(sales_pct + purchases_pct).round(2)}% 100%);margin-bottom:14px;border:1px solid #e5e7eb;" do
          end
          ul style: "list-style:none;padding:0;margin:0;" do
            li style: "margin-bottom:6px;" do
              span style: "display:inline-block;width:10px;height:10px;background:#22c55e;border-radius:50%;margin-right:8px;"
              text_node "Sales: #{number_with_delimiter(total_sales_value.round(2))} Rs (#{sales_pct.round(1)}%)"
            end
            li style: "margin-bottom:6px;" do
              span style: "display:inline-block;width:10px;height:10px;background:#3b82f6;border-radius:50%;margin-right:8px;"
              text_node "Purchases: #{number_with_delimiter(total_purchase_value.round(2))} Rs (#{purchases_pct.round(1)}%)"
            end
            li do
              span style: "display:inline-block;width:10px;height:10px;background:#f97316;border-radius:50%;margin-right:8px;"
              text_node "Expenses: #{number_with_delimiter(total_expenses.round(2))} Rs (#{expenses_pct.round(1)}%)"
            end
          end
        end
      end
    end
  end
end

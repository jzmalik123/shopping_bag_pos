ActiveAdmin.register_page "Profit And Loss" do
  menu priority: 11, label: "Profit & Loss"

  content title: "Profit & Loss Statement" do
    parsed_start_date = Date.parse(params[:start_date]) rescue nil
    parsed_end_date = Date.parse(params[:end_date]) rescue nil
    start_date = parsed_start_date || Date.current.beginning_of_month
    end_date = parsed_end_date || Date.current.end_of_month
    end_date = start_date if end_date < start_date

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

    month_starts = []
    cursor_date = start_date.beginning_of_month
    while cursor_date <= end_date
      month_starts << cursor_date
      cursor_date = cursor_date.next_month
    end

    monthly_profits = month_starts.map do |month_start|
      month_end = [month_start.end_of_month, end_date].min
      month_start_in_range = [month_start, start_date].max

      month_sales = Order.where(order_date: month_start_in_range..month_end).sum(:total_amount).to_f
      month_purchases = VendorOrder.where(order_date: month_start_in_range..month_end).includes(:vendor_order_items).sum do |vendor_order|
        vendor_order.vendor_order_items.sum(&:amount).to_f
      end
      month_expenses = Expense.where(expense_date: month_start_in_range..month_end).sum(:amount).to_f

      {
        label: month_start.strftime("%b %Y"),
        value: (month_sales - month_purchases - month_expenses).round(2)
      }
    end

    max_abs_profit = monthly_profits.map { |item| item[:value].abs }.max.to_f

    panel "Filters" do
      div do
        form action: admin_profit_and_loss_path, method: :get do
          div style: "display:flex;gap:12px;align-items:flex-end;flex-wrap:wrap;" do
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

    panel "Statement for #{start_date.strftime('%d %b %Y')} - #{end_date.strftime('%d %b %Y')}" do
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

    panel "Monthly Profit Chart (Selected Range)" do
      if monthly_profits.empty?
        div "No data found for selected range."
      else
        div style: "display:flex;gap:14px;align-items:flex-end;min-height:260px;padding:12px 8px;border:1px solid #e5e7eb;background:#fff;overflow-x:auto;" do
          monthly_profits.each do |item|
            bar_height = max_abs_profit.positive? ? ((item[:value].abs / max_abs_profit) * 180.0) : 0
            bar_color = item[:value] >= 0 ? "#22c55e" : "#ef4444"

            div style: "min-width:90px;text-align:center;" do
              div style: "font-size:12px;margin-bottom:6px;color:#334155;" do
                text_node "#{number_with_delimiter(item[:value])} Rs"
              end
              div style: "display:flex;justify-content:center;align-items:flex-end;height:190px;" do
                div style: "width:44px;height:#{bar_height}px;background:#{bar_color};border-radius:6px 6px 0 0;" do
                end
              end
              div style: "font-size:12px;margin-top:8px;color:#475569;" do
                text_node item[:label]
              end
            end
          end
        end
        div style: "margin-top:10px;font-size:12px;color:#475569;" do
          span style: "display:inline-block;width:10px;height:10px;background:#22c55e;border-radius:50%;margin-right:6px;"
          text_node "Profit"
          span style: "display:inline-block;width:10px;height:10px;background:#ef4444;border-radius:50%;margin:0 6px 0 14px;"
          text_node "Loss"
        end
      end
    end
  end
end

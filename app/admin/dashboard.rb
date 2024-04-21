# In app/admin/dashboard.rb

ActiveAdmin.register_page "Dashboard" do

  # Custom page content
  content title: 'Todays Data' do
    @total_received_amount = Order.where('created_at >= ?', Time.zone.now.beginning_of_day).sum(&:received_amount)
    @total_received_payments = Payment.with_payment_type(:incoming).where('created_at >= ?', Time.zone.now.beginning_of_day).sum(:amount)
    columns do
      column do
        panel '' do
          h1 do
            link_to("+ Create Order", new_admin_order_path)
          end
        end
      end
      column do
        panel '' do
          h1 do
            link_to("+ Create Payment", new_admin_payment_path)
          end
        end
      end
    end
    columns do
      column do
        panel "Today's Orders" do
          h1 "#{number_with_delimiter @total_received_amount} Rs"
        end
      end
      
      column do
        panel "Incoming Payments" do
          h1 " #{ number_with_delimiter @total_received_payments} Rs"
        end
      end

      column do
        panel "Total Payments" do
          h1 " #{ number_with_delimiter(@total_received_payments + @total_received_amount)} Rs"
        end
      end
    end
    columns do
      column do
        panel "Total Weight Sold" do
          h1 "#{number_with_delimiter Order.where('created_at >= ?', Time.zone.now.beginning_of_day).sum(&:total_weight)} KG"
        end
      end
      
      column do
        panel "Today's Sold Number of Bags" do
          h1 "#{OrderItem.where('created_at >= ?', Time.zone.now.beginning_of_day).sum(:quantity)}"
        end
      end
    end
  end
end

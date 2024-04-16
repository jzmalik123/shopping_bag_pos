# In app/admin/dashboard.rb

ActiveAdmin.register_page "Dashboard" do

  # Custom page content
  content title: 'Todays Data' do
    columns do
      @total_payments = 0
      column do
        panel "Today's Orders" do
          h1 "#{number_with_delimiter Order.where('created_at >= ?', Time.zone.now.beginning_of_day).sum(&:received_amount)} Rs"
        end
      end
      
      column do
        panel "Incoming Payments" do
          h1 " #{ number_with_delimiter Payment.with_payment_type(:incoming).where('created_at >= ?', Time.zone.now.beginning_of_day).sum(:amount)} Rs"
        end
      end

      column do
        panel "Total Payments" do
          para "Total bags sold today: #{OrderItem.where('created_at >= ?', Time.zone.now.beginning_of_day).sum(:quantity)}"
        end
      end
    end
    columns do
      column do
        panel "Weight" do
          h1 "#{number_with_delimiter Order.where('created_at >= ?', Time.zone.now.beginning_of_day).sum(&:received_amount)} Rs"
        end
      end
      
      column do
        panel "Today's Sold Number of Bags" do
          para "Total bags sold today: #{OrderItem.where('created_at >= ?', Time.zone.now.beginning_of_day).sum(:quantity)}"
        end
      end
    end
  end
end

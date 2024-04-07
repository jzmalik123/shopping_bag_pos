class Customer < ApplicationRecord

  has_many :payments, as: :source
  has_many :orders
  
  WALKIN_CUSTOMER_ID = 1
end

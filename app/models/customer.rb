class Customer < ApplicationRecord

  has_many :payments, as: :source
  WALKIN_CUSTOMER_ID = 1
end

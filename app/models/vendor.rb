class Vendor < ApplicationRecord
  has_many :payments, as: :source
end

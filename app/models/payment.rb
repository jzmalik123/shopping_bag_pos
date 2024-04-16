class Payment < ApplicationRecord
  belongs_to :source, polymorphic: true

  extend Enumerize
  enumerize :payment_method, in: [:cash, :bank_alfalah, :bank_meezan]
  enumerize :payment_type, in: [:incoming, :outgoing], predicates: true, scope: true
end

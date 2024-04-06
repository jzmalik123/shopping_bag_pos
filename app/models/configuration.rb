class Configuration < ApplicationRecord

  def self.default_sale_date
    self.find_by_key('default_sale_rate').value
  end
end

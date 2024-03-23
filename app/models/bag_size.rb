class BagSize < ApplicationRecord

  def self.sizes
    pluck(:size)
  end

  def self.sizes_options
    BagSize.all.map{|bagsize| [bagsize.size, bagsize.id]}
  end
end

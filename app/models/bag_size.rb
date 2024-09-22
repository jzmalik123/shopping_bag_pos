class BagSize < ApplicationRecord

  belongs_to :bag_type

  def self.sizes
    pluck(:size)
  end

  def self.sizes_options
    # Fetch all BagSize objects and group them by bag_type.name
    BagSize.includes(:bag_type).group_by { |bagsize| bagsize.bag_type.name }.transform_values do |bags|
      # For each group, map the bag sizes into [size, id] pairs
      bags.map { |bagsize| [bagsize.size, bagsize.id] }
    end
  end
end

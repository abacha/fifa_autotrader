module Concerns
  module Masked
    def masked_all
      all.each do |item|
        item.mask
      end
    end
  end
end

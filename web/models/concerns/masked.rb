# frozen_string_literal: true

module Concerns
  module Masked
    def masked_all
      all.each(&:mask)
    end
  end
end

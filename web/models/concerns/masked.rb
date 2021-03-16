# frozen_string_literal: true

module Concerns
  module Masked
    def masked_all
      all.order(:key).each(&:mask)
    end
  end
end

# frozen_string_literal: true

require './lib/cache'
require './web/models/concerns/masked'

class Setting < ActiveRecord::Base
  extend Concerns::Masked
  after_save :clear_cache

  def clear_cache
    Cache.store.delete("SETTINGS_#{key}")
  end

  def self.groups
    Setting.pluck(:group).uniq
  end

  def self.get(key)
    Cache.fetch("SETTINGS_#{key}") do
      find_by(key: key)&.value
    end
  end

  def mask
    self.value = '*' * 16 if secure == 1
    self
  end
end

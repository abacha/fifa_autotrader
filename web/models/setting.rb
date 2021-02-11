class Setting < ActiveRecord::Base
  after_save :clear_cache
  def clear_cache
    Cache.store.delete("SETTINGS_#{key}")
  end

  def self.get(key)
    Cache.fetch("SETTINGS_#{key}") do
      find_by(key: key).value
    end
  end
end

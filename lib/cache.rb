require 'active_support/cache'

class Cache
  include Singleton
  attr_accessor :store

  def self.store
    instance.store ||= ActiveSupport::Cache::MemoryStore.new(expires_in: 3600)
  end

  def self.read(key)
    store.read key
  end

  def self.write(key, value)
    store.write(key, value)
  end

  def self.fetch(key, &block)
    store.fetch(key) { yield }
  end
end

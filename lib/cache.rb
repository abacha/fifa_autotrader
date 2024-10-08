# frozen_string_literal: true

require 'active_support/cache'

class Cache
  include Singleton
  attr_accessor :store

  def self.store
    instance.store ||= ActiveSupport::Cache::MemoryStore.new(expires_in: 1800)
  end

  def self.read(key)
    store.read key
  end

  def self.write(*params)
    store.send(:write, *params)
  end

  def self.fetch(*params, &block)
    store.send(:fetch, *params) { block.call }
  end

  def self.delete(key)
    store.delete key
  end
end

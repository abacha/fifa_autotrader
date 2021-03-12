# frozen_string_literal: true

class PlayerSnipe < ActiveRecord::Base
  RARITY_FILE = ENV['RARITY_FILE']

  validates :name, :fullname, :max_bid, :quality, presence: true
  validate :check_rarity

  def self.rarities
    YAML.safe_load(File.read(RARITY_FILE))
  end

  def check_rarity
    errors.add(:rarity, :invalid) if rarity && !Player.rarities.include?(rarity)
  end
end

# frozen_string_literal: true

class Stock
  STOCK_FILE = 'stock.csv'

  def self.save(auction_data)
    CSV.open(STOCK_FILE, 'wb') do |csv|
      auction_data.to_a.map { |line| csv.puts line }
    end

    ElkLogger.log(:info, { msg: 'Stock updated' })
  end

  def self.all
    CSV.read(STOCK_FILE).to_h
  end

  def self.by_player(player_name)
    data = all.detect { |name, _| name == player_name }
    data ? data[1].to_i : 0
  end
end

require 'csv'

Trade = Struct.new(:timestamp, :kind, :player_name,
                   :start_price, :sold_for, :buy_now) do

  TRADE_FILE = 'players_trades.csv'

  def self.all
    CSV.read(TRADE_FILE)[1..-1].map do |line|
      Trade.new(line[0], line[1], line[2], line[3].to_i, line[4].to_i, line[5].to_i)
    end
  end

  def self.by_player(player_name)
    all.select do |trade|
      trade.player_name == player_name
    end
  end

  def self.save(value_data)
    CSV.open(TRADE_FILE, 'a+') do |csv|
      csv << value_data.values_at(:timestamp,
                                  :kind,
                                  :name,
                                  :start_price,
                                  :current_bid,
                                  :buy_now)
    end
  end
end

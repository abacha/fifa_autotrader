# frozen_string_literal: true

class Stock
  STOCK_FILE = "#{ENV['TMP_FOLDER']}/stock.yml"

  def self.save(auctions)
    File.open(STOCK_FILE, 'w') { |file| file.write(auctions.to_yaml) }
  end

  def self.data
    all.map do |auction|
      auction.to_h.slice(:start_price, :current_bid, :buy_now, :timeleft, :player_name)
    end
  end

  def self.all
    Cache.fetch('stock', expires_in: 60) do
      YAML.safe_load(File.read(STOCK_FILE))
    end
  end

  def self.count
    all.each_with_object(Hash.new(0)) { |e, h| h[e.player_name] += 1; }
  end

  def self.by_player(player_name)
    data = count.detect { |name, _| name == player_name }
    data ? data[1].to_i : 0
  end

  def self.full_stock
    grouped = Stock.all.group_by(&:player_name)

    grouped.map do |player_name, stocks|
      trades = Trade.where(matched: 0, kind: 'B', player_name: player_name)
      0.upto(stocks.size - 1).map do |i|
        OpenStruct.new(
          player_name: player_name,
          buy_price: trades[i]&.sold_for,
          buy_timestamp: trades[i]&.timestamp,
          sell_price: stocks[i].start_price,
          timeleft: stocks[i].timeleft,
          current_bid: stocks[i].current_bid
        )
      end
    end.flatten.sort_by { |line| line.buy_timestamp || Time.now }
  end
end

require 'csv'

class Manager
  def self.calculate
    data =
      Player.all.map do |player|
        consolidated = OpenStruct.new(name: player.name,
                                      total: 0,
                                      avg_buy_price: 0,
                                      avg_sell_price: 0,
                                      amount_sell: 0,
                                      amount_buy: 0,
                                      stock: 0)

        Trade.by_player(player.name).map do |trade|
          consolidated.total += trade.kind == 'B' ? -trade.sold_for : trade.sold_for
          if trade.kind == 'B'
            consolidated.avg_buy_price = (consolidated.avg_buy_price + trade.sold_for)/2
            consolidated.amount_buy += 1
            consolidated.last_buy = trade.timestamp
            consolidated.stock += 1
          else
            consolidated.avg_sell_price = (consolidated.avg_buy_price + trade.sold_for)/2
            consolidated.amount_sell += 1
            consolidated.last_sell = trade.timestamp if trade.kind == 'S'
            consolidated.stock -= 1
          end
        end
        [player.name, consolidated]
      end
    Hash[data]
  end

  def self.report
    self.calculate.each do |player_name, consolidated|
      ap consolidated
    end
  end
end

require 'csv'

class Manager
  def self.calculate
    Player.all.map do |player|
      consolidated = OpenStruct.new(name: player.name,
                                    total: 0,
                                    amount_sell: 0,
                                    amount_buy: 0,
                                    stock: 0)

      Trade.by_player(player.name).map do |trade|
        consolidated.total += trade.kind == 'B' ? -trade.sold_for : trade.sold_for
        if trade.kind == 'B'
          consolidated.amount_buy += 1
          consolidated.last_buy = trade.timestamp
          consolidated.stock += 1
        else
          consolidated.amount_sell += 1
          consolidated.last_sell = trade.timestamp if trade.kind == 'S'
          consolidated.stock -= 1
        end
        p trade if consolidated.stock < 0
      end
      consolidated
    end
  end
end

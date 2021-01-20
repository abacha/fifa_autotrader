class PlayerReport
  EA_TAX = 5
  attr_reader :player_name, :total_sold, :total_bought, :amount_sold, :amount_bought

  def initialize(player_name)
    @player_name = player_name
    @total_sold = 0
    @total_bought = 0
    @amount_sold = 0
    @amount_bought = 0
  end

  def add_trade(trade)
    if trade.kind == 'B'
      @total_bought += trade.sold_for
      @amount_bought += 1
      @last_bought = trade.timestamp
    else
      @total_sold += trade.sold_for
      @amount_sold += 1
      @last_sold = trade.timestamp
    end

  end

  def report
    {
      player_name: player_name,
      stock: stock,
      profit: profit,
      avg_profit: avg_profit,
      avg_buy_price: avg_buy_price,
      avg_sell_price: avg_sell_price,
      avg_safe_rate: avg_safe_rate
    }
  end

  def profit
    -total_bought + (total_sold * 1-EA_TAX/100)
  end

  def avg_safe_rate
    (avg_profit / avg_buy_price.to_f * 100).to_i
  end

  def avg_profit
    profit / amount_sold
  end

  def stock
    amount_bought - amount_sold
  end

  def avg_buy_price
    total_bought / amount_bought if amount_bought > 0
  end

  def avg_sell_price
    total_sold / amount_sold if amount_sold > 0
  end
end

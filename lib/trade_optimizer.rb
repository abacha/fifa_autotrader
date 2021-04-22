# frozen_string_literal: true

class TradeOptimizer
  def self.optimize_value(futbin_value)
    max_bid = [(futbin_value * get('BID_RATIO').to_f / 100).to_i * 100, get('MIN_BID').to_i].max
    sell_value = [(futbin_value * get('SELL_RATIO').to_f / 100).to_i * 100, get('MIN_SELL').to_i].max

    { max_bid: max_bid, sell_value: fix_value(sell_value) }
  end

  private

  def self.fix_value(value)
    value_string = value.to_s

    if value > 10_000
      ending = value_string[-3..].to_i
      fixed_value = if ending < 250
                      '000'
                    elsif ending < 750
                      '500'
                    else
                      '750'
                    end
      "#{value_string[0..-4]}#{fixed_value}".to_i
    else
      (value / 100.0).to_i * 100
    end
  end
end

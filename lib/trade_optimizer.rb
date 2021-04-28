# frozen_string_literal: true

class TradeOptimizer
  BID_RATIO = Setting.get('BID_RATIO').to_f
  SELL_RATIO = Setting.get('SELL_RATIO').to_f
  MIN_SELL = Setting.get('MIN_SELL').to_i
  MIN_BID = Setting.get('MIN_BID').to_i

  def self.values(futbin_value)
    max_bid = [(futbin_value * BID_RATIO / 100).to_i * 100, MIN_BID].max
    sell_value = [(futbin_value * SELL_RATIO / 100).to_i * 100, MIN_SELL].max

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

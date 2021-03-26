# frozen_string_literal: true

class MarketListerPartial < BasePage
  class MixedValueError < StandardError; end

  def list(player)
    click_on 'List on Transfer Market'

    set_input(0, player.sell_value)
    gap = player.sell_value > 10_000 ? 250 : 100
    set_input(1, player.sell_value + gap)

    click_on 'List for Transfer'
    sleep 5
    RobotLogger.msg("Player listed to market: #{player.name} ($#{player.sell_value})")
  end

  private

  def set_input(index, value)
    panel_path = '.panelActions.open .panelActionRow'
    input = all("#{panel_path} input")[index]
    fill_input(input, value)
    first(panel_path).click
    sleep 1

    raise MixedValueError, "MIXED VALUE: #{text_to_number(input.value)} != #{value}" if text_to_number(input.value) != value
  end
end

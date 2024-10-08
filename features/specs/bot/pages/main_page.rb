# frozen_string_literal: true

class MainPage < BasePage
  MARKET_INTERVAL = Setting.get('MARKET_INTERVAL').to_i
  AUTO_OPTIMIZE_VALUES = Setting.get('AUTO_OPTIMIZE_VALUES').to_i

  def execute
    login.execute

    @last_market = 0
    i = 1
    while true
      start_time = Time.now.to_i
      Command.check_all
      process(i)
      sleep 10
      elapsed_time = ChronicDuration.output(Time.now.to_i - start_time)
      RobotLogger.msg("Run: #{i} (ET: #{elapsed_time})")
      i += 1
    end
  end

  def process(i)
    do_process do
      Stock.diff

      if AUTO_OPTIMIZE_VALUES == 1 && i % 10 == 0
        RobotLogger.msg 'Optimizing player values'
        PlayerTrade.actives.each(&:optimize_value)
        RobotLogger.msg 'Player values optimized!'
      end
      transfer_list.clear_sold
      transfer_list.relist_players
      transfer_list.update_stock

      transfer_target.clear_bids

      time_diff = (Time.now - @last_market).to_i
      if time_diff >= MARKET_INTERVAL
        time_output = ChronicDuration.output(time_diff, format: :short)
        RobotLogger.msg(
          "Last market time was #{time_output} ago, going to market!"
        )
        market.buy_players
        @last_market = Time.now
      end

      market.snipe_players

      loop do
        transfer_target.renew_bids
        bids = transfer_target.list_bids
        outbid = bids.detect { |bid| bid.status == 'outbid' }
        min_time = outbid&.timeleft ? outbid.timeleft : 1_000
        break if min_time > 120
      end
    end
  end

  def do_process(&block)
    block.call
  rescue Selenium::WebDriver::Error::WebDriverError,
         Capybara::CapybaraError => e

    error_msg = e.message
    dialog = '.Dialog'

    error_msg = find(dialog).text if has_css?(dialog)

    ErrorHandler.bot_verification
    ErrorHandler.handle(error_msg)
  end
end

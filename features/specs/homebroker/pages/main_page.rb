# frozen_string_literal: true

class MainPage < BasePage
  def execute
    login.execute

    @last_market = 0
    i = 1
    while true
      start_time = Time.now.to_i
      process(i)
      Command.check_all
      sleep 10
      elapsed_time = ChronicDuration.output(Time.now.to_i - start_time)
      RobotLogger.msg("Run: #{i} (ET: #{elapsed_time})")
      i += 1
    end
  end

  def process(i)
    do_process do
      transfer_list.clear_sold
      transfer_list.relist_players
      transfer_list.update_stock

      bids = transfer_target.list_bids

      if bids.detect { |bid| bid.status == 'expired' }
        transfer_target.clear_expired
      end

      if bids.detect { |bid| bid.status == 'won' }
        transfer_target.clear_bought
      end

      time_diff = (Time.now - @last_market).to_i
      if time_diff >= (MarketPage::MAX_TIME_LEFT - 90)
        time_output = ChronicDuration.output(time_diff, format: :short)
        RobotLogger.msg(
          "Last market time was #{time_output} ago, going to market!")
        market.buy_players
        @last_market = Time.now
      end

      loop do
        transfer_target.renew_bids
        bids = transfer_target.list_bids
        outbid = bids.detect { |bid| bid.status == 'outbid' }
        min_time = (outbid&.timeleft) ? outbid.timeleft : 1_000
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

    if has_css?(dialog)
      error_msg = find(dialog).text
    end

    ErrorHandler.bot_verification
    ErrorHandler.handle(error_msg)
  end
end

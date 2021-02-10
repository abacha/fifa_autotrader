# frozen_string_literal: true

class MainPage < BasePage
  def execute
    login.execute

    i = 1
    while true
      start_time = Time.now.to_i
      process(i)
      pause?
      sleep 10
      elapsed_time = ChronicDuration.output(Time.now.to_i - start_time)
      RobotLogger.msg("Run: #{i} (ET: #{elapsed_time})")
      i += 1
    end
  end

  def process(i)
    do_process do
      if i % 3 == 0
        transfer_target.clear_expired
      end

      if i % 2 == 0
        transfer_list.clear_sold
        transfer_list.relist_players
      end

      if i % 5 == 0
        market.buy_players
      end

      loop do
        transfer_target.renew_bids
        bids = transfer_target.list_bids
        if bids.detect { |bid| bid.status == 'won' }
          transfer_target.clear_bought
        end
        outbid = bids.detect { |bid| bid.status == 'outbid' }
        min_time = (outbid && outbid.timeleft) ? outbid.timeleft : 1_000
        break if min_time > 120
      end

      transfer_list.update_stock
    end
  end

  def do_process(&block)
    begin
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

  private

  def pause?
    if File.exists?('pause')
      FileUtils.rm_f('pause')
      binding.pry
    end
  end
end

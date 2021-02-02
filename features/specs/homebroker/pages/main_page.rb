# frozen_string_literal: true

class MainPage < BasePage
  def execute
    login.execute

    i = 1
    while true
      start_time = Time.now.to_i

      process(i)

      elapsed_time = ChronicDuration.output(Time.now.to_i - start_time)

      pause?

      sleep 10
      RobotLogger.log(:info, { run: i, elapsed_time: elapsed_time })
      i += 1
    end
  end

  def process(i)
    do_process do
      if i % 3 == 0
        transfer_list.update_stock
        transfer_target.clear_expired
      end

      if i % 5 == 0
        market.buy_players
        transfer_list.clear_sold
      end

      transfer_list.relist_players

      bids = transfer_target.list_bids
      outbid = bids.detect { |bid| bid.status == 'outbid' }
      min_time = (outbid && outbid.timeleft) ? outbid.timeleft : 1_000
      transfer_target.renew_bids if min_time < 180

      if bids.detect { |bid| bid.status == 'won' }
        transfer_target.clear_bought
      end
    end
  end

  def do_process(&block)
    begin
      block.call
    rescue Selenium::WebDriver::Error::WebDriverError, Capybara::CapybaraError => e
      RobotLogger.log(:error, { msg: e.inspect })
      error_msg = e.message
      dialog = '.ui-dialog-type-alert'

      if has_css?(dialog)
        error_msg = find(dialog).text
        RobotLogger.log(:error, { dialog: error_msg })
      end

      HooksConfig.record_error(error_msg)

      bot_verification

      ErrorHandler.handle(error_msg)
    end
  end

  private

  def pause?
    binding.pry if File.exists?('pause')
    FileUtils.rm_f('pause')
  end
end

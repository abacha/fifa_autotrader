# frozen_string_literal: true

class BasePage
  include Capybara::DSL

  def go
    raise NotImplementedError unless respond_to?(:execute)

    begin
      send(:execute)
    rescue StandardError => e
      raise e
    end
  end

  def n(number)
    number.gsub(',', '').to_i
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

      if error_msg.match(/Your Transfer Targets list is full/)
        transfer_target.clear_expired
      elsif error_msg.match(/You cannot unwatch an item you are bidding on/)
        click_on 'Ok'
      elsif error_msg.match(/You are already the highest bidder/)
        click_on 'CANCEL'
      elsif error_msg.match(/BID TOO LOW/)
        click_on 'Ok'
      elsif error_msg.match(/Unable to authenticate with the FUT servers/)
        exit 1
      elsif error_msg.match(/VERIFICATION REQUIRED/)
        page.refresh
      elsif error_msg.match(/NO INTERNET CONNECTION/)
        exit 1
      elsif has_css?('.loaderIcon')
        sleep 30
        exit 1if  has_css?('.loaderIcon')
      end
    end
  end

  def bot_verification
    return unless has_css?('div', text: 'VERIFICATION REQUIRED')

    while has_css?('div', text: 'VERIFICATION REQUIRED')
      RobotLogger.log(:warn, { msg: 'Bot Verification' })
      page.refresh
      sleep 30
    end

    RobotLogger.log(:info, { msg: 'Verification Success!' })
  end

  private

  def fill_input(input, value)
    find(input).click
    find(input).set value
  end
end

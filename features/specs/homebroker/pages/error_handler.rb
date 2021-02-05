class ErrorHandler < BasePage
  include Singleton

  def self.handle(error_msg)
    instance.handle(error_msg)
  end

  def handle(error_msg)
    if error_msg.match(/LOGIN UNAVAILABLE/)
      exit 1
    elsif error_msg.match(/Your Transfer Targets list is full/)
      transfer_target.clear_expired
      RobotLogger.log(:warn, 'Transfer targets list full')
    elsif error_msg.match(/You cannot unwatch an item you are bidding on/)
      click_on 'Ok'
    elsif error_msg.match(/You are already the highest bidder/)
      click_on 'CANCEL'
    elsif error_msg.match(/BID TOO LOW/)
      click_on 'Ok'
    elsif error_msg.match(/Unable to authenticate with the FUT servers/)
      RobotLogger.log(:error, 'Unable to authenticate with the FUT servers')
      exit 1
    elsif error_msg.match(/VERIFICATION REQUIRED/)
      page.refresh
    elsif has_css?('.ut-logged-on-console')
      RobotLogger.log(:warn, 'Logged on another device')
      sleep 600
      page.refresh
    elsif error_msg.match(/NO INTERNET CONNECTION/)
      RobotLogger.log(:error, 'No internet connection')
      exit 1
    elsif error_msg.match(/Sorry, an error has occurred/)
      RobotLogger.log(:error, error_msg)
      exit 1
    elsif has_css?('.loaderIcon')
      sleep 30
      RobotLogger.log(:error, 'Eternal loading')
      exit 1 if has_css?('.loaderIcon')
    else
      HooksConfig.record_error(error_msg)
      RobotLogger.log(:error, error_msg)
    end
  end

  def self.bot_verification
    instance.bot_verification
  end

  def bot_verification
    return unless has_css?('div', text: 'VERIFICATION REQUIRED')

    while has_css?('div', text: 'VERIFICATION REQUIRED')
      RobotLogger.log(:warn, 'Bot Verification')
      page.refresh
      sleep 30
    end

    RobotLogger.msg('Verification Success!')
  end
end

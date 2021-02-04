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
    elsif has_css?('.ut-logged-on-console')
      sleep 300
      page.refresh
    elsif error_msg.match(/NO INTERNET CONNECTION/)
      exit 1
    elsif error_msg.match(/SIGNED INTO ANOTHER DEVICE/)
      exit 0
    elsif error_msg.match(/Sorry, an error has occurred/)
      exit 1
    elsif has_css?('.loaderIcon')
      sleep 30
      exit 1 if has_css?('.loaderIcon')
    end
  end

  def self.bot_verification
    instance.bot_verification
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
end

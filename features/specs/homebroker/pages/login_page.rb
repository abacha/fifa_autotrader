# frozen_string_literal: true

require_relative '../../../../lib/mail_service'
class LoginPage < BasePage
  SECURITY_FILE = 'security_code'

  def execute
    sleep 10
    click_on 'Login'
    sleep 5
    fill_in 'email', with: ENV['ORIGIN_EMAIL']
    fill_in 'password', with: ENV['ORIGIN_PASSWORD']
    click_on 'Log In'
    click_on 'Send Security Code'
    fill_in('oneTimeCode', with: security_code)
    click_on 'Log In'

    sleep 10

    if has_css?('.origin-ux-textbox-status-message')
      click_on 'Resend my security code'
    end
  end

  private

  def security_code
    while (security_code = MailService.security_code).nil?
      RobotLogger.log(:info, { msg: 'Waiting for security code' })
      sleep 10
    end
    RobotLogger.log(:info, { msg: 'Security code loaded' })

    security_code
  end

  def load_cookies
    browser = Capybara.current_session.driver.browser.manage
    cookies = CSV.read('cookies.csv')
    cookies.each do |cookie|
      browser.add_cookie(
        name: cookie[0],
        value: cookie[1],
        path: cookie[2],
        domain: cookie[3],
        expires: DateTime.parse(cookie[4]),
        secure: cookie[5] == 'true'
      )
    end
  end
end

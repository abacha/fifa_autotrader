# frozen_string_literal: true

require_relative '../../../../lib/mail_service'
class LoginPage < BasePage
  SECURITY_FILE = 'security_code'

  def execute
    click_on 'Login'
    sleep 5
    fill_in 'email', with: ENV['ORIGIN_EMAIL']
    fill_in 'password', with: ENV['ORIGIN_PASSWORD']
    click_on 'Log In'
    click_on 'Send Security Code'
    fill_in('oneTimeCode', with: security_code)
    click_on 'Log In'
    sleep 5
  end

  private

  def security_code
    while MailService.security_code.nil?
      ElkLogger.log(:info, { msg: 'Waiting for security code' })
      sleep 10
    end
    ElkLogger.log(:info, { msg: 'Security code loaded' })

    MailService.security_code
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

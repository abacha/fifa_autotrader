# frozen_string_literal: true

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
    FileUtils.rm(SECURITY_FILE)
    sleep 5
  end

  private

  def security_code
    sleep 1 while !File.exists?(SECURITY_FILE)
    ElkLogger.log(:info, { msg: 'Security code loaded' })

    File.read(SECURITY_FILE).chomp
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

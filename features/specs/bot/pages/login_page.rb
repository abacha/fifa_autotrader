# frozen_string_literal: true

class LoginPage < BasePage
  SECURITY_FILE = 'security_code'

  def execute
    sleep 10
    click_on 'Login'
    sleep 5
    fill_form
    sleep 10

    if has_css?('.origin-ux-textbox-status-message')
      RobotLogger.msg('Asking for a new security code in one minute')
      sleep 65
      click_on 'Resend my security code'
    end
  end

  private

  def fill_form
    fill_in 'email', with: Setting.get('ORIGIN_EMAIL')
    fill_in 'password', with: Setting.get('ORIGIN_PASSWORD')
    click_on 'Log In'
    click_on 'Send Security Code'
    fill_in('oneTimeCode', with: security_code)
    click_on 'Log In'
  end

  def security_code
    while (security_code = MailService.security_code).nil?
      RobotLogger.msg('Waiting for security code')
      sleep 10
    end
    RobotLogger.msg('Security code loaded')

    security_code
  end
end

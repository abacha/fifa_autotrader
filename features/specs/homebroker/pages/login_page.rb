# frozen_string_literal: true

class LoginPage < BasePage
  def execute
    sleep 10
    login
    binding.pry
  end

  def login
    click_on 'Login'
    sleep 5
    fill_in 'email', with: 'abacha@gmail.com'
    fill_in 'password', with: 'psur_ept5tras9JUR'
    click_on 'Log In'
    click_on 'Send Security Code'
    code = 1
    binding.pry
    fill_in('oneTimeCode', with: code)
    click_on 'Log In'
    sleep 6
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

  def process
    do_process do
      list = transfer_target.list

      outbid = list.detect { |bid| bid[:status] == 'outbid' }
      min_time = outbid ? ChronicDuration.parse(outbid[:timeleft]) : 1_000

      transfer_target.renew_bids if min_time < 180

      if list.detect { |bid| bid[:status] == 'won' }
        transfer_target.clear
      end

      transfer_target.clear_expired
      transfer_list.clear

      market.buy_players
    end
  end

  private

  def market
    MarketPage.new
  end

  def transfer_list
    TransferListPage.new
  end

  def transfer_target
    TransferTargetPage.new
  end
end

# frozen_string_literal: true

class MainPage < BasePage
  def execute
    sleep 10
    login.execute
    sleep 10
    cycle
  end

  def cycle(n = 8)
    runs = n * 60 * 60 / 300
    1.upto(runs) do |i|
      start_time = Time.now.to_i
      process
      elapsed_time = Time.now.to_i - start_time
      ElkLogger.log(
        :info, { run: i, elapsed_time: ChronicDuration.output(elapsed_time), total: runs }
      )
      sleep 120
    end
  end

  def process
    do_process do
      list = transfer_target.list

      outbid = list.detect { |bid| bid[:status] == 'outbid' }
      min_time = (outbid && outbid[:timeleft]) ? outbid[:timeleft] : 1_000

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

  def login
    LoginPage.new
  end
end

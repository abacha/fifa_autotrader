# frozen_string_literal: true

class MainPage < BasePage
  def execute
    login.execute

    i = 1
    while true
      start_time = Time.now.to_i

      process

      elapsed_time = ChronicDuration.output(Time.now.to_i - start_time)

      ElkLogger.log(:info, { run: i, elapsed_time: elapsed_time })

      sleep 120
      i += 1
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
      transfer_list.update_stock

      market.buy_players

      pause?
    end
  end

  private

  def pause?
    binding.pry if File.exists?('pause')
    FileUtils.rm_f('pause')
  end

  def market
    @market ||= MarketPage.new
  end

  def transfer_list
    @transfer_list ||= TransferListPage.new
  end

  def transfer_target
    @transfer_target ||= TransferTargetPage.new
  end

  def login
    @login ||= LoginPage.new
  end
end

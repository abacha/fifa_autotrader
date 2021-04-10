# frozen_string_literal: true

module ApplicationPresenter
  def total(list, method)
    list.sum do |item|
      item.send(method)
    end
  end

  def money(value)
    number_to_currency(value, precision: 0)
  end

  def time(value)
    ChronicDuration.output(value, format: :short) if value
  end

  def datetime(value)
    value.strftime('%Y-%m-%d %H:%M:%S')
  end

  def futbin_sales_url(player)
    "#{Futbin::URL_BASE}/21/sales/#{player.futbin_id}"
  end
end

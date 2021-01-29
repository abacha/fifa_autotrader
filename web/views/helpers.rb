helpers do
  def total(list, method)
    list.sum do |item|
      item.send(method)
    end
  end

  def money(value)
    number_to_currency(value, precision: 0)
  end
end

# frozen_string_literal: true

class FundsPage < BasePage
  def execute
    wait_for_pageload
    click_on 'AÇÕES'
    wait_for_pageload
    click_on 'MOEDAS'
    wait_for_pageload
    click_on 'INVESTIMENTO EXTERIOR'
    wait_for_pageload
    click_on 'MULTIMERCADO'
    wait_for_pageload
  end
end

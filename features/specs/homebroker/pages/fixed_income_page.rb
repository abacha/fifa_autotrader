# frozen_string_literal: true

class FixedIncomePage < BasePage
  def execute
    wait_for_pageload
    click_on 'LCI'
    wait_for_pageload
    click_on 'CDB'
    wait_for_pageload
    click_on 'LCA'
    wait_for_pageload
    click_on 'LC'
    wait_for_pageload
  end
end

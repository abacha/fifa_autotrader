# frozen_string_literal: true

Before do |_scenario|
  window = Capybara.current_session.current_window
  window.resize_to(1366, 768)
  window.maximize

  @page = lambda do |klass|
    klass.new
  end
end

# frozen_string_literal: false

module ScreenshotSetup
  include Capybara::DSL

  # rubocop:disable Lint/Debugger
  def take_screenshot(scenario)
    datetime = Time.now.strftime('%Y%m%d_%H%M%S_%L')
    scenario_name = scenario.name.gsub(
      %r{([_@#!%()\-=;><,{}~\[\]./?"*\^$+\-]+)}, '_'
    )
    screenshot =
      "#{Dir.pwd}/log/screenshots/#{scenario_name}/#{datetime}.png".
      tr(' ', '_')
    save_screenshot(screenshot)
  end
  # rubocop:enable Lint/Debugger
end

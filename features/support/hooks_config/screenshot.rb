# frozen_string_literal: false

module ScreenshotSetup
  include Capybara::DSL

  # rubocop:disable Lint/Debugger
  def record_error(message)
    id = rand(1000)
    datetime = Time.now.strftime('%Y%m%d_%H%M%S_%L')
    File.write("#{Dir.pwd}/tmp/errors/#{id}_#{datetime}.log", message)
    save_screenshot("#{Dir.pwd}/tmp/screenshots/#{id}_#{datetime}.png")
    save_page("#{Dir.pwd}/tmp/pages/#{id}_#{datetime}.png")
  end
  # rubocop:enable Lint/Debugger
end

# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
Capybara.configure do |config|
  case ENV['BROWSER']
  when 'chrome'
    @driver = :selenium_chrome
  when 'chrome_headless'
    Capybara.register_driver :selenium_chrome_headless do |app|
      chrome_options = Selenium::WebDriver::Chrome::Options.new.tap do |options|
        options.add_argument '--headless'
        options.add_argument '--disable-gpu'
        options.add_argument '--no-sandbox'
        options.add_argument '--disable-site-isolation-trials'
        options.add_argument '--disable-dev-shm-usage'
        options.add_argument '--window-size=1024,768'
      end
      Selenium::WebDriver.logger.level = :error
      Capybara::Selenium::Driver.new(
        app, browser: :chrome, options: chrome_options
      )
    end
    @driver = :selenium_chrome_headless
  end

  config.default_driver = @driver
  config.app_host = 'https://www.ea.com/fifa/ultimate-team/web-app'
  config.default_max_wait_time = ENV.fetch('MAX_WAIT_TIME', 10).to_i
end
# rubocop:enable Metrics/BlockLength

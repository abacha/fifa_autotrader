# frozen_string_literal: true

module ErrorCapturer
  include Capybara::DSL
  ERRORS_FOLDER = "#{ENV['TMP_FOLDER']}/errors"

  def self.record_error(message)
    id = rand(1000)
    datetime = Time.now.strftime('%Y%m%d_%H%M%S_%L')
    basename = "#{ERRORS_FOLDER}/#{datetime}_#{id}"
    File.write("#{basename}.log", message)
    save_screenshot("#{basename}.png")
    save_page("#{basename}.html")
  end
end

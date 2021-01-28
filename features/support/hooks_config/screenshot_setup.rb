# frozen_string_literal: false

module ScreenshotSetup
  include Capybara::DSL

  # rubocop:disable Lint/Debugger
  def record_error(message)
    id = rand(1000)
    datetime = Time.now.strftime('%Y%m%d_%H%M%S_%L')
    File.write("#{Dir.pwd}/tmp/errors/#{datetime}_#{id}.log", message)
    save_screenshot("#{Dir.pwd}/tmp/screenshots/#{datetime}_#{id}.png")
    save_page("#{Dir.pwd}/tmp/pages/#{datetime}_#{id}.html")
  end
  # rubocop:enable Lint/Debugger

  def self.last_error
    image = Dir['public/screenshots/*.png'].sort.last

    if image
      hash = image.match(/\/(\d{3}_.*?)\./)[1]
      img_path = image.gsub('public', '')
      timestamp = image.match(/\d{8}_\d{6}/)[0]
      error_msg = File.read("tmp/errors/#{hash}.log")

      OpenStruct.new(
        img_path: img_path,
        error_msg: error_msg,
        timestamp: DateTime.parse(timestamp).strftime('%Y-%m-%d %H:%M:%S')
      )
    else
      OpenStruct.new
    end
  end
end

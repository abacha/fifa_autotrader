# frozen_string_literal: true

require 'logger'
require 'singleton'

class RobotLogger
  include Singleton

  LOG_FILE = "#{ENV['TMP_FOLDER']}/logs/robot.log"

  def self.log(severity, msg)
    instance.log(severity, msg)
  end

  def self.msg(msg)
    instance.log(:info, msg)
  end

  def logger
    @logger ||=
      begin
        log = Logger.new(LOG_FILE, 'daily')
        log.formatter = proc do |severity, datetime, _progname, msg|
          date_format = datetime.strftime('%Y-%m-%d %H:%M:%S')
          "[#{date_format}] #{severity[0]}: #{msg}\n"
        end
        log
      end
  end

  def log(severity, msg)
    puts "[#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}] #{msg}"
    logger.send(severity, msg)
  end

  def self.tail(lines = 100)
    `tail -n#{lines} #{LOG_FILE}`
  end
end

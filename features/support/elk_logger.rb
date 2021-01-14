# frozen_string_literal: true

require 'logstash-logger'
require 'singleton'

class ElkLogger
  include Singleton

  BASE_URL = ENV['LOGSTASH_URL']
  LOG_PROTOCOL = ENV.fetch('LOGSTASH_PROTOCOL', 'udp')
  LOGSTASH_TAG = ENV.fetch('LOGSTASH_TAG', 'AUTOMACAO_FEATURE')
  PORT = ENV.fetch('LOGSTASH_PORT', 5000)

  def self.log(severity, msg)
    instance.log(severity, msg)
  end

  def logstash
    @logstash ||=
      LogStashLogger.new(type: LOG_PROTOCOL, host: BASE_URL, port: PORT)
  end

  def log(severity, msg)
    # msg.merge!(uuid: uuid)
    puts msg
    # logstash.tagged(LOGSTASH_TAG) do
    #  logstash.send(severity, msg.to_json)
    # end
  end

  def uuid
    @uuid ||= SecureRandom.uuid.split('-').join
  end
end

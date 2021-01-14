# frozen_string_literal: true

class BasePage
  include Capybara::DSL

  attr_reader :elements

  def initialize
    raw_elements = YAML.load_file('features/specs/homebroker/elements.yml')
    @elements = OpenStruct.new(raw_elements[self.class.name])
  end

  def page_name
    self.class.name
  end

  def go
    raise NotImplementedError unless respond_to?(:execute)

    log('Iniciando')
    begin
      send(:execute)
      log('Finalizando')
    rescue StandardError => e
      log('Erro')
      raise e
    end
  end

  def log(msg)
    ElkLogger.log(:debug, page_name: page_name, message: msg)
  end
end

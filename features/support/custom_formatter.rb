# frozen_string_literal: true

class ElkLogger
  class CucumberFormatter
    NANOSECONDS_PER_SECOND = 1_000_000_000

    def initialize(_runtime, io, _options)
      @io = io
    end

    def after_test_case(test_case, result)
      feature = test_case.source.first.short_name.upcase
      scenario = test_case.source.last.name.upcase
      report = build_report(test_case, result)
      ElkLogger.log(:info, report.merge(feature: feature, scenario: scenario))
    end

    private

    def build_report(test_case, result)
      {
        test_status: result.ok?,
        duration: result.duration.nanoseconds.to_f / NANOSECONDS_PER_SECOND,
        tags: test_case.tags.map(&:name),
        exception_msg: (result.exception unless result.ok?)
      }
    end
  end
end

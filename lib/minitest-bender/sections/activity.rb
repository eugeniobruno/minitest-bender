module MinitestBender
  module Sections
    class Activity
      def initialize(io, started_at, results)
        @io = io
        @started_at = started_at
        @results = results
      end

      def print
        total_tests = "#{test_count} tests"
        total_tests = total_tests.chop if test_count == 1
        formatted_total_tests = Colorizer.colorize(total_tests, :tests)

        total_assertions = "#{assertion_count} assertions"
        total_assertions = total_assertions.chop if assertion_count == 1
        formatted_total_assertions = Colorizer.colorize(total_assertions, :assertions)

        auxiliary_verb = test_count == 1 ? 'was' : 'were'

        total_time = (Time.now - started_at).round(3)
        formatted_total_time = Colorizer.colorize("#{total_time} seconds", :time)

        tests_rate = Colorizer.colorize("#{(test_count / total_time).round(4)} tests/s", :time)
        assertions_rate = Colorizer.colorize("#{(assertion_count / total_time).round(4)} assertions/s", :time)

        io.puts "  #{formatted_total_tests} with #{formatted_total_assertions} #{auxiliary_verb} run in #{formatted_total_time} (#{tests_rate}, #{assertions_rate})"
        io.puts
      end

      private

      attr_reader :io, :started_at, :results

      def test_count
        results.size
      end

      def assertion_count
        @assertion_count ||= results.reduce(0) { |acum, result| acum + result.assertions }
      end
    end
  end
end

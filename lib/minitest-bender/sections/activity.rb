module MinitestBender
  module Sections
    class Activity
      TIME_UNITS = %w[day hour minute second].freeze

      def initialize(io, started_at, results)
        @io = io
        @started_at = started_at
        @results = results
      end

      def print
        io.puts "  #{formatted_total_tests} with #{formatted_total_assertions} #{auxiliary_verb} run in #{formatted_total_time} (#{formatted_tests_rate}, #{formatted_assertions_rate})"
        io.puts
      end

      private

      attr_reader :io, :started_at, :results

      def formatted_total_tests
        Colorizer.colorize(total_tests, :tests)
      end

      def formatted_total_assertions
        Colorizer.colorize(total_assertions, :assertions)
      end

      def auxiliary_verb
        test_count == 1 ? 'was' : 'were'
      end

      def formatted_total_time
        Colorizer.colorize(total_time_string, :time)
      end

      def formatted_tests_rate
        Colorizer.colorize("#{tests_rate} tests/s", :time)
      end

      def formatted_assertions_rate
        Colorizer.colorize("#{assertions_rate} assertions/s", :time)
      end

      def tests_rate
        (test_count / total_time).round(4)
      end

      def assertions_rate
        (assertion_count / total_time).round(4)
      end

      def total_tests
        "#{test_count} test#{test_count == 1 ? '' : 's'}"
      end

      def total_assertions
        "#{assertion_count} assertion#{assertion_count == 1 ? '' : 's'}"
      end

      def test_count
        results.size
      end

      def assertion_count
        @assertion_count ||= results.reduce(0) { |acum, result| acum + result.assertions }
      end

      def total_time_string
        minutes, seconds = total_time.divmod(60)
        hours, minutes = minutes.divmod(60)
        days, hours = hours.divmod(24)

        values = [days, hours, minutes]
        seconds_decimals = values.all?(&:zero?) ? 3 : 0
        values.push(seconds.round(seconds_decimals))

        values_with_units = values.map.with_index do |value, index|
          unit = time_units[index]
          value > 0 ? "#{value} #{unit}#{value.to_s == '1' ? '' : 's'}" : ''
        end

        Utils.english_join(values_with_units)
      end

      def total_time
        @total_time ||= Time.now - started_at
      end

      def time_units
        TIME_UNITS
      end
    end
  end
end

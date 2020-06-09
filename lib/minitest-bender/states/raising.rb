# coding: utf-8
# frozen_string_literal: true

module MinitestBender
  module States
    class Raising < Base
      COLOR = :amber_300
      LABEL = 'RAISED'
      GROUP_LABEL = 'ERRORS'
      ICON = '💥'

      attr_accessor :backtrace_view

      def initialize
        @backtrace_view = :user
      end

      def formatted_message(result)
        colored(error_message(result))
      end

      def summary_message(results)
        filtered_results = only_with_this_state(results)
        return '' if filtered_results.empty?
        colored("#{filtered_results.size} raised an error")
      end

      def test_location(result)
        backtrace_line = user_backtrace(result).select do |line|
          File.dirname(line) == '.' || line =~ %r{(^|/)(test|spec)/}
        end.last
        if backtrace_line
          Utils.relative_path(backtrace_line).split(':').first
        else
          "(test location can't be deduced from backtrace)"
        end
      end

      private

      def do_print_details(io, result, padding)
        io.puts "#{padding}#{colored(error_message(result))}"
        backtrace(result).each do |line|
          io.puts "#{padding}#{Colorizer.colorize(:brown_400, line)}"
        end
      end

      def error_message(result)
        exception = result.failures[0].exception
        "#{exception.class}: #{exception.message}"
      end

      def backtrace(result)
        case backtrace_view
        when :user
          user_backtrace(result)
        when :full
          full_backtrace(result)
        else
          raise "unknown backtrace view: #{backtrace_view}"
        end
      end

      def user_backtrace(result)
        full_backtrace(result).take_while do |line|
          line !~ %r{minitest/test\.rb}
        end
      end

      def full_backtrace(result)
        # Minitest::UnexpectedError: SystemStackError: stack level too deep
        result.failures[0].backtrace || ['']
      end
    end
  end
end

# coding: utf-8
# frozen_string_literal: true

module MinitestBender
  module States
    class Raising < Base
      COLOR = :error
      LABEL = 'RAISED'
      GROUP_LABEL = 'ERRORS'
      ICON = '💥'

      def formatted_message(result)
        colored(error_message(result))
      end

      def summary_message
        return '' if results.empty?
        colored("#{results.size} raised an error")
      end

      def test_location(result)
        Utils.relative_path(result.file_path)
      end

      private

      def inner_detail_lines(result, padding)
        lines = []
        message = colored(error_message(result))
        lines << "#{padding}#{message.gsub("\n", "\n#{padding}")}"
        backtrace(result).each do |line|
          lines << "#{padding}#{Colorizer.colorize(line, :backtrace)}"
        end
        lines
      end

      def error_message(result)
        error = result.failures[0].error
        "#{error.class}: #{error.message}"
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

      def backtrace_view
        Minitest::Bender.configuration.backtrace_view
      end

      def user_backtrace(result)
        full_backtrace(result).take_while do |line|
          line !~ %r{minitest/test\.rb}
        end
      end

      def full_backtrace(result)
        result.failures[0].backtrace || []
      end
    end
  end
end

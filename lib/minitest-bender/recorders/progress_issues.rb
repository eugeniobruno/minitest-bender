module MinitestBender
  module Recorders
    class ProgressIssues
      def initialize(io, total_tests_count)
        @printer = Printers::WithProgressBar.new(io, total_tests_count)
      end

      def print_context(_result_context)
        # do nothing
      end

      def print_result(result)
        printer.print_line(result_line(result)) unless result.passed?
        lines = result.state.detail_lines_without_header(result)
        printer.print_lines(lines)
        printer.advance
      end

      def print_context_with_results(_result_context, _results)
        # do_nothing
      end

      private

      attr_reader :printer

      def result_line(result)
        "  #{result.formatted_label_and_time}#{result.formatted_number} #{result.formatted_name_with_context}"
      end
    end
  end
end

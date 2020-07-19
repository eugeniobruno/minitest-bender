module MinitestBender
  module Recorders
    class ProgressVerbose
      def initialize(io, total_tests_count)
        @printer = Printers::WithProgressBar.new(io, total_tests_count)
      end

      def print_context(result_context)
        printer.print_line
        printer.print_line(Colorizer.colorize(result_context.with_prefix, :normal, :bold))
      end

      def print_result(result)
        printer.print_line(result_line(result))
        lines = result.state.detail_lines_without_header(result)
        padded_lines = lines.map { |line| "  #{line}" }
        printer.print_lines(padded_lines)
        printer.advance
      end

      def print_context_with_results(_result_context, _results)
        # do_nothing
      end

      private

      attr_reader :printer

      def result_line(result)
        "    #{result.formatted_label_and_time}#{result.formatted_number} #{result.name}"
      end
    end
  end
end

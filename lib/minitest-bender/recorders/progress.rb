module MinitestBender
  module Recorders
    class Progress
      def initialize(io, total_tests_count)
        @printer = Printers::WithProgressBar.new(io, total_tests_count)
      end

      def print_context(_result_context)
        # do nothing
      end

      def print_result(result)
        printer.advance
      end

      def print_context_with_results(_result_context, _results)
        # do_nothing
      end

      private

      attr_reader :printer
    end
  end
end

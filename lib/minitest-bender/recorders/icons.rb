module MinitestBender
  module Recorders
    class Icons
      def initialize(io)
        @printer = Printers::Plain.new(io)
      end

      def print_context(_result_context)
        # do nothing
      end

      def print_result(result)
        printer.print(result.to_icon)
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

module MinitestBender
  module Recorders
    class None
      def print_context(_result_context)
        # do nothing
      end

      def print_result(_result)
        # do nothing
      end

      def print_context_with_results(_result_context, _results)
        # do_nothing
      end
    end
  end
end

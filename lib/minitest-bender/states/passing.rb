module MinitestBender
  module States
    class Passing < Base
      COLOR = :green_500
      LABEL = 'PASSED'.freeze
      GROUP_LABEL = 'PASSING'.freeze

      def formatted_message(_result)
        ''
      end

      def print_details(_io, _results)
        :no_details
      end

      def summary_message(results)
        filtered_results = only_with_this_state(results)
        return '' if filtered_results.empty?
        colored("#{filtered_results.size} passed")
      end
    end
  end
end

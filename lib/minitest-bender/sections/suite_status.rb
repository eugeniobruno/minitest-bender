module MinitestBender
  module Sections
    class SuiteStatus
      def initialize(io, options_args, results)
        @io = io
        @options_args = options_args
        @results = results
      end

      def print
        final_divider_color = all_passed_color

        if all_run_tests_passed? && all_tests_were_run?
          message = Colorizer.colorize('  ALL TESTS PASS!  (^_^)/', all_passed_color)
        else
          messages = MinitestBender.states.values.map do |state|
            summary_message = state.summary_message
            final_divider_color = state.color unless summary_message.empty?
            summary_message
          end

          message = "  #{Utils.english_join(messages)}"
        end
        io.puts(message)

        print_divider(final_divider_color)
      end

      private

      attr_reader :io, :options_args, :results

      def all_passed_color
        :pass
      end

      def all_run_tests_passed?
        test_count == passed_count
      end

      def test_count
        results.size
      end

      def passed_count
        @passed_count ||= results.count(&:passed?)
      end

      def all_tests_were_run?
        !restricted_run?
      end

      def restricted_run?
        options_args =~ /(?:^-n.*)|(?:--name=)|(?:-l\s?\d)|(?:--line(?:\s|=)\d)/
      end

      def print_divider(color)
        io.puts(Colorizer.colorize("  #{'_' * 23}", color, :bold))
        io.puts
      end
    end
  end
end

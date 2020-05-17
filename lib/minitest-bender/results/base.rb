module MinitestBender
  module Results
    class Base
      extend Forwardable
      def_delegators :@minitest_result, :passed?, :skipped?, :assertions, :failures, :time

      def initialize(minitest_result)
        @minitest_result = minitest_result
        @state = MinitestBender.states.fetch(minitest_result.result_code)
      end

      def context
        @context ||=
          if minitest_result.respond_to?(:klass) # minitest >= 5.11
            minitest_result.klass
          else
            minitest_result.class.name
          end.gsub('::', ' > ')
      end

      def header
        Colorin.white("• #{context}").bold
      end

      def compact
        state.tag
      end

      def details_header(number)
        "    #{number}#{Colorin.white(context)} > #{name}"
      end

      def rerun_line(padding)
        unformatted = "Rerun: #{rerun_command}"
        "#{padding}#{Colorin.blue_a700(unformatted)}"
      end

      def state?(some_state)
        state.class == some_state.class
      end

      def line_for_slowness_podium
        "#{formatted_time} #{Colorin.white(context)} > #{name}"
      end

      private

      attr_reader :minitest_result, :state

      def formatted_label
        "    #{state.formatted_label}"
      end

      def formatted_message
        " #{state.formatted_message(self)}"
      end

      def formatted_time
        time_in_s = time
        time_with_unit =
          case time_in_s
          when 0...1
            sprintf('%.0fms ', time_in_s * 1000)
          when 1...10
            sprintf('%.2fs ', time_in_s)
          when 10...100
            sprintf('%.1fs ', time_in_s)
          when 100...10000
            sprintf('%.0fs ', time_in_s)
          else
            sprintf('%.0fs', time_in_s)
          end
        Colorin.grey_700(time_with_unit.rjust(6))
      end

      def rerun_command
        relative_location = state.test_location(self).split(':').first
        "rake TEST=#{relative_location} TESTOPTS=\"--name=#{name_for_rerun_command}\""
      end
    end
  end
end

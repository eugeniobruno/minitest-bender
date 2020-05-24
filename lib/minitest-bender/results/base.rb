# coding: utf-8
# frozen_string_literal: true
require 'forwardable'

module MinitestBender
  module Results
    class Base
      extend Forwardable
      def_delegators :@minitest_result, :passed?, :skipped?, :assertions, :failures, :time
      attr_reader :state, :execution_order

      CLASS_SEP = ' ▸ '
      NAME_SEP =  ' ◆ '

      def initialize(minitest_result)
        @minitest_result = minitest_result
        @state = MinitestBender.states.fetch(minitest_result.result_code)
        @execution_order = @state.incr
      end

      def context
        @context ||=
          if minitest_result.respond_to?(:klass) # minitest >= 5.11
            minitest_result.klass
          else
            minitest_result.class.name
          end.gsub('::', CLASS_SEP)
      end

      def header
        Colorizer.colorize(:white, "• #{context}").bold
      end

      def to_icon
        state.colored_icon
      end

      def details_header(number)
        "    #{number}#{Colorizer.colorize(:white, context)}#{NAME_SEP}#{name}"
      end

      def rerun_line(padding)
        unformatted = "Rerun: #{rerun_command}"
        "#{padding}#{Colorizer.colorize(:blue_a700, unformatted)}"
      end

      def state?(some_state)
        state.class == some_state.class
      end

      def line_for_slowness_podium
        "#{formatted_time} #{Colorizer.colorize(:white, context)}#{NAME_SEP}#{name}"
      end

      private

      attr_reader :minitest_result

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
        Colorizer.colorize(:grey_700, time_with_unit.rjust(6))
      end

      def rerun_command
        relative_location = state.test_location(self).split(':').first
        "rake TEST=#{relative_location} TESTOPTS=\"--name=#{name_for_rerun_command}\""
      end
    end
  end
end

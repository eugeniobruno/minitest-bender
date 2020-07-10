# coding: utf-8
# frozen_string_literal: true

require 'forwardable'

module MinitestBender
  module Results
    class Base
      extend Forwardable
      def_delegators :@minitest_result, :passed?, :skipped?, :assertions, :failures, :time
      attr_reader :state, :execution_order

      NAME_PREFIX = '♦'

      def initialize(minitest_result)
        @minitest_result = minitest_result
        @state = MinitestBender.states.fetch(minitest_result.result_code)
        @execution_order = state.add_result(self).size
      end

      def context
        @context ||= ResultContext.new(adjusted_class_name)
      end

      def to_icon
        state.colored_icon
      end

      def name_sort_key
        name
      end

      def formatted_name_with_context
        "#{Colorizer.colorize(context, :normal)} #{name_prefix} #{Colorizer.colorize(name, :normal, :bold)}"
      end

      def rerun_line(padding)
        unformatted = "Rerun: #{rerun_command}"
        "#{padding}#{Colorizer.colorize(unformatted, :tests)}"
      end

      def formatted_label
        state.formatted_label
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
        Colorizer.colorize(time_with_unit.rjust(6), :time)
      end

      def formatted_label_and_time
        "#{formatted_label} #{formatted_time}"
      end

      def formatted_message
        state.formatted_message(self)
      end

      def file_path
        @file_path ||= source_location[0]
      end

      def source_line_number
        @source_line_number ||= source_location[1]
      end

      # credit where credit is due: minitest-line
      def source_location
        if minitest_at_least_5_11?
          minitest_result.source_location
        else
          minitest_result.method(minitest_result.name).source_location rescue ['unknown', -1]
        end
      end

      private

      attr_reader :minitest_result

      def adjusted_class_name
        class_name
      end

      def class_name
        if minitest_at_least_5_11?
          minitest_result.klass
        else
          minitest_result.class.name
        end
      end

      def minitest_at_least_5_11?
        @minitest_at_least_5_11 ||= Gem.loaded_specs['minitest'].version >= Gem::Version.new('5.11')
      end

      def class_separator
        CLASS_SEPARATOR
      end

      def name_prefix
        NAME_PREFIX
      end

      def rerun_command
        return unless (relative_location = state.test_location(self))

        relative_location = relative_location.split(':').first

        stem = Minitest::Bender.configuration.rerun_command_stem

        if stem.include?('rake')
          "#{stem} TEST=#{relative_location} TESTOPTS=\"--name=#{name_for_rerun_command}\""
        else
          "#{stem} #{relative_location} --name=#{name_for_rerun_command}"
        end
      end
    end
  end
end

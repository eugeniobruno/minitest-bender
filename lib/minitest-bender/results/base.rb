# coding: utf-8
# frozen_string_literal: true
require 'forwardable'

module MinitestBender
  module Results
    class Base
      extend Forwardable
      def_delegators :@minitest_result, :passed?, :skipped?, :assertions, :failures, :time
      attr_reader :state, :execution_order

      CLASS_SEPARATOR = '::'
      CONTEXT_SEPARATOR = ' ▸ '
      NAME_PREFIX = '♦ '
      HEADER_PREFIX = '• '

      def initialize(minitest_result)
        @minitest_result = minitest_result
        @state = MinitestBender.states.fetch(minitest_result.result_code)
        @execution_order = state.add_result(self).size
      end

      def context
        @context ||= context_path.join(context_separator)
      end

      def context_path
        class_name.split(class_separator)
      end

      def context_separator
        CONTEXT_SEPARATOR
      end

      def to_icon
        state.colored_icon
      end

      def header_prefix
        HEADER_PREFIX
      end

      def formatted_header_prefix
        Colorizer.colorize(header_prefix, :normal, :bold)
      end

      def formatted_name_with_context
        "#{Colorizer.colorize(context, :normal)} #{name_prefix}#{Colorizer.colorize(name, :normal, :bold)}"
      end

      def rerun_line(padding)
        unformatted = "Rerun: #{rerun_command}"
        "#{padding}#{Colorizer.colorize(unformatted, :tests)}"
      end

      def formatted_label
        "    #{state.formatted_label}"
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

      def formatted_message
        state.formatted_message(self)
      end

      def file_path
        source_location[0]
      end

      # credit where credit is due: minitest-line
      def source_location
        if minitest_at_least_5_11?
          minitest_result.source_location
        else
          minitest_result.method(minitest_result.name).source_location
        end
      end

      private

      attr_reader :minitest_result

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

        prefix = Minitest::Bender.configuration.run_command

        if prefix.include?('rake')
          "#{prefix} TEST=#{relative_location} TESTOPTS=\"--name=#{name_for_rerun_command}\""
        else
          "#{prefix} #{relative_location} --name=#{name_for_rerun_command}"
        end
      end
    end
  end
end

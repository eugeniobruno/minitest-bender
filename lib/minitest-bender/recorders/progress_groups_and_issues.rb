module MinitestBender
  module Recorders
    class ProgressGroupsAndIssues
      def initialize(io, total_tests_count)
        @printer = Printers::WithProgressBar.new(io, total_tests_count)
        @total_tests_count = total_tests_count
      end

      def print_context(_result_context)
        # do nothing
      end

      def print_result(result)
        printer.print_line(result_line(result)) unless result.passed?
        lines = result.state.detail_lines_without_header(result)
        lines << '' unless lines.empty?
        lines.each { |line| printer.print_line(line.sub('  ', '')) }
        printer.advance
      end

      def print_context_with_results(result_context, results)
        context_path = result_context.path
        context_separator = result_context.separator
        prefix = result_context.prefix

        path = context_path[0...-1].join(context_separator)
        path << context_separator unless path.empty?
        klass = context_path.last

        printer.print_line("#{prefix}#{counters(result_context)} #{path}#{Colorizer.colorize(klass, :normal, :bold)}")
        printer.print_line
      end

      private

      attr_reader :printer, :total_tests_count

      def result_line(result)
        "  #{result.formatted_label_and_time}#{result.formatted_number} #{result.formatted_name_with_context}"
      end

      def counters(result_context)
        states.map do |state|
          state.colored_icon_with_context_count(result_context, counters_padding_right)
        end.join('  ')
      end

      def states
        @states ||= MinitestBender.states.values
      end

      def counters_padding_right
        @counters_padding_right ||= total_tests_count.to_s.size + 1
      end
    end
  end
end

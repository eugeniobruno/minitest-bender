module MinitestBender
  module States
    class Base
      attr_reader :results

      def initialize
        @results = []
      end

      def add_result(result)
        results.push(result)
      end

      def formatted_label
        @formatted_label ||= colored(label.ljust(7))
      end

      def formatted_group_label
        @formatted_group_label ||= "  #{colored(group_label, :bold, :underline)}"
      end

      def colored_icon
        colored(icon)
      end

      def colored_icon_with_count(padding_right = 0)
        with_colored_icon(results.size, padding_right)
      end

      def colored_icon_with_context_count(result_context, padding_right = 0)
        context_count = results.count { |r| r.context == result_context }
        with_colored_icon(context_count, padding_right)
      end

      def print_details(io)
        return :no_details if results.empty?

        sorted_results = results.sort_by(&:source_location)

        io.puts formatted_group_label
        io.puts
        sorted_results.each_with_index do |result, i|
          detail_lines(result).each { |line| io.puts line }
          io.puts if i < results.size - 1
        end
        io.puts
        :printed_details
      end

      def detail_lines(result)
        number = "#{result.execution_order})".ljust(4)
        padding = ' ' * (number.size + 4)
        time = "(#{result.time_with_unit_and_padding_right.strip})"
        lines = []
        lines << "    #{number}#{result.formatted_name_with_context} #{Colorizer.colorize(time, :time)}"

        lines += inner_detail_lines(result, padding)

        lines << ''
        lines << rerun_line(result, padding)
        lines.compact
      end

      def detail_lines_without_header(result)
        number = "#{result.execution_order})".ljust(4)
        padding = ' ' * (number.size + 2)
        lines = []

        lines += inner_detail_lines(result, padding).tap do |ls|
          ls[0] = "  #{number}#{ls[0].strip}" unless ls.empty?
        end

        lines << ''
        lines << rerun_line(result, padding)
        lines << ''
        lines.compact
      end

      def color
        self.class::COLOR
      end

      def test_location(result)
        location(result)
      end

      private

      def label
        self.class::LABEL
      end

      def group_label
        self.class::GROUP_LABEL
      end

      def icon
        self.class::ICON
      end

      def colored(string, *args)
        Colorizer.colorize(string, color, *args)
      end

      def with_colored_icon(message, padding_right)
        colored("#{icon}#{message}".ljust(padding_right, ' '))
      end

      def inner_detail_lines(result, padding)
        lines = []
        result.failures[0].message.split("\n").each do |line|
          line.split("\\n").each do |actual_line|
            adjusted_line = Utils.with_home_shorthand(actual_line)
            lines << "#{padding}#{colored(adjusted_line)}"
          end
        end
        lines << backtrace(result, padding)
        lines.compact
      end

      def backtrace(result, padding)
        "#{padding}#{Colorizer.colorize(location(result), :backtrace)}:"
      end

      def rerun_line(result, padding)
        result.rerun_line(padding)
      end

      def location(result)
        Utils.relative_path(result.failures[0].location)
      end
    end
  end
end

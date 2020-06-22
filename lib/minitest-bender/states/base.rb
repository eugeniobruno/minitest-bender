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
        lines = []
        lines << result.details_header(number)

        lines += inner_detail_lines(result, padding)

        lines << ''
        lines << result.rerun_line(padding)
        lines
      end

      def detail_lines_without_header(result)
        number = "#{result.execution_order})".ljust(4)
        padding = ' ' * (number.size + 4)
        lines = []

        lines += inner_detail_lines(result, padding).tap do |ls|
          ls[0] = "    #{number}#{ls[0].strip}" unless ls.empty?
        end

        lines << ''
        lines << result.rerun_line(padding)
        lines
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

      def inner_detail_lines(result, padding)
        lines = []
        result.failures[0].message.split("\n").each do |line|
          lines << "#{padding}#{colored(line)}"
        end
        lines << "#{padding}#{Colorizer.colorize(location(result), :backtrace)}:"
        lines
      end

      def location(result)
        Utils.relative_path(result.failures[0].location)
      end
    end
  end
end

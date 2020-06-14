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
          print_detail(io, result)
          io.puts if i < results.size - 1
        end
        io.puts
        :printed_details
      end

      def print_detail(io, result)
        number = "#{result.execution_order})".ljust(4)
        padding = ' ' * (number.size + 4)
        io.puts(result.details_header(number))
        do_print_details(io, result, padding)
        io.puts
        io.puts(result.rerun_line(padding))
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

      def do_print_details(io, result, padding)
        result.failures[0].message.split("\n").each do |line|
          io.puts "#{padding}#{colored(line)}"
        end
        io.puts "#{padding}#{Colorizer.colorize(location(result), :backtrace)}:"
      end

      def location(result)
        Utils.relative_path(result.failures[0].location)
      end
    end
  end
end

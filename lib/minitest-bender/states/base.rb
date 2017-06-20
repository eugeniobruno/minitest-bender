module MinitestBender
  module States
    class Base
      def formatted_label
        @formatted_label ||= colored(label.ljust(7))
      end

      def formatted_group_label
        @formatted_group_label ||= "  #{colored(group_label).bold.underline}"
      end

      def print_details(io, results)
        filtered_results = only_with_this_state(results)
        return :no_details if filtered_results.empty?

        io.puts formatted_group_label
        io.puts
        filtered_results.each_with_index do |result, i|
          number = "#{i + 1})".ljust(4)
          padding = ' ' * (number.size + 4)
          io.puts(result.details_header(number))
          do_print_details(io, result, padding)
          io.puts
          io.puts(result.rerun_line(padding))
          io.puts if i < filtered_results.size - 1
        end
        io.puts
        :printed_details
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

      def colored(string)
        Colorin.public_send(color, string)
      end

      def only_with_this_state(results)
        results.select { |result| result.state?(self) }
      end

      def do_print_details(io, result, padding)
        result.failures[0].message.split("\n").each do |line|
          io.puts "#{padding}#{colored(line)}"
        end
        io.puts "#{padding}#{Colorin.brown_400(location(result))}"
      end

      def location(result)
        Utils.relative_path(result.failures[0].location)
      end
    end
  end
end

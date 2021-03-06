module MinitestBender
  module Sections
    class TimeRanking
      def initialize(io, size, results)
        @io = io
        @size = size
        @results = results
      end

      def print
        return if trivial?

        io.puts(formatted_label)
        io.puts
        sorted_results_to_show.each_with_index do |result, i|
          number = "#{i + 1})".ljust(4)
          io.puts "    #{number}#{result.formatted_time} #{result.formatted_name_with_context}"
        end
        print_divider
        io.puts
      end

      private

      attr_reader :io, :size, :results

      def trivial?
        size < 1 || results.size < 2
      end

      def formatted_label
        "  #{Colorizer.colorize('TIME RANKING', :time, :bold, :underline)}"
      end

      def sorted_results_to_show
        sorted_results.take(size)
      end

      def sorted_results
        results.sort_by { |r| -r.time }
      end

      def print_divider
        io.puts(Colorizer.colorize("  #{'_' * 23}", :normal, :bold))
        io.puts
      end
    end
  end
end

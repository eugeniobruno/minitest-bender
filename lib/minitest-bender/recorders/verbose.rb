module MinitestBender
  module Recorders
    class Verbose
      def initialize(io)
        @io = io
      end

      def print_context(result_context)
        io.puts
        io.puts(Colorizer.colorize(result_context.with_prefix, :normal, :bold))
      end

      def print_result(result)
        io.puts("#{result.formatted_label}#{result.formatted_time}#{result.formatted_number} #{result.name}")
        lines = result.state.detail_lines_without_header(result)
        lines << '' unless lines.empty?
        lines.each { |line| io.puts line }
      end

      private

      attr_reader :io
    end
  end
end

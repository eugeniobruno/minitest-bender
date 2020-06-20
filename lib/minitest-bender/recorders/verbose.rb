module MinitestBender
  module Recorders
    class Verbose
      def initialize(io)
        @io = io
      end

      def print_header(result)
        io.puts
        io.puts(result.header_for_verbose_recorder)
      end

      def print_content(result)
        io.puts(result.line_for_verbose_recorder)
        result.state.print_detail(io, result)
      end

      private

      attr_reader :io
    end
  end
end

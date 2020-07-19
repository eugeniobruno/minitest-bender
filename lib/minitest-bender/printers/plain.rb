module MinitestBender
  module Printers
    class Plain
      def initialize(io)
        @io = io
      end

      def print(string)
        io.print(string)
      end

      def print_line(line = '')
        io.puts(line)
      end

      def print_lines(lines)
        lines.each { |line| print_line(line) }
      end

      def advance
        # do nothing
      end

      private

      attr_reader :io
    end
  end
end

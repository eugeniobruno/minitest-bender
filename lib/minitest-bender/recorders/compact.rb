module MinitestBender
  module Recorders
    class Compact
      def initialize(io)
        @io = io
      end

      def print_header(result)
        io.print("#{result.header_for_compact_recorder} ")
      end

      def print_content(result)
        io.print(result.to_icon)
      end

      private

      attr_reader :io
    end
  end
end

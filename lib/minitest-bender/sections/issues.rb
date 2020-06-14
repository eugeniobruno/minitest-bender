module MinitestBender
  module Sections
    class Issues
      def initialize(io)
        @io = io
      end

      def print
        symbols = states.map { |state| state.print_details(io) }
        io.puts unless symbols.all? { |symbol| symbol == :no_details }
      end

      private

      attr_reader :io

      def states
        MinitestBender.states.values
      end
    end
  end
end

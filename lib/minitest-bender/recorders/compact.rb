module MinitestBender
  module Recorders
    class Compact
      def initialize(io)
        @io = io
      end

      def print_context(result_context)
        io.puts

        context_path = result_context.path
        context_separator = result_context.separator
        prefix = result_context.prefix

        path = context_path[0...-1].join(context_separator)
        path << context_separator unless path.empty?
        klass = context_path.last

        io.print("#{prefix}#{path}#{Colorizer.colorize(klass, :normal, :bold)} ")
      end

      def print_result(result)
        io.print(result.to_icon)
      end

      private

      attr_reader :io
    end
  end
end

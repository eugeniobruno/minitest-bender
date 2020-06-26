module MinitestBender
  module Recorders
    class Compact
      def initialize(io)
        @io = io
      end

      def print_header(result)
        io.puts

        context_path = result.context_path
        context_separator = result.context_separator
        prefix = result.formatted_header_prefix

        path = context_path[0...-1].join(context_separator)
        path << context_separator unless path.empty?
        klass = context_path.last

        io.print("#{prefix}#{path}#{Colorizer.colorize(klass, :normal, :bold)} ")
      end

      def print_content(result)
        io.print(result.to_icon)
      end

      private

      attr_reader :io
    end
  end
end

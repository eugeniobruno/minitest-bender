module MinitestBender
  module Recorders
    class GroupedIcons
      def initialize(io)
        @printer = Printers::Plain.new(io)
      end

      def print_context(result_context)
        printer.print_line

        context_path = result_context.path
        context_separator = result_context.separator
        prefix = result_context.prefix

        path = context_path[0...-1].join(context_separator)
        path << context_separator unless path.empty?
        klass = context_path.last

        printer.print("#{prefix}#{path}#{Colorizer.colorize(klass, :normal, :bold)} ")
      end

      def print_result(result)
        printer.print(result.to_icon)
        printer.advance
      end

      def print_context_with_results(_result_context, _results)
        # do_nothing
      end

      private

      attr_reader :printer
    end
  end
end

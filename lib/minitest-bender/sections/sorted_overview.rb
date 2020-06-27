module MinitestBender
  module Sections
    class SortedOverview
      def initialize(io, results_by_context)
        @io = io
        @results_by_context = results_by_context
      end

      def print
        return if trivial?

        io.puts(formatted_label)
        io.puts
        split_context = []
        results_by_context.sort.each do |context, results|
          io.puts
          split_context = print_header(results.first, split_context)
          words = []
          results.sort_by(&:sort_key).each do |result|
            words = print_result_line(result, words)
          end
        end
        io.puts
        print_divider
      end

      private

      attr_reader :io, :results_by_context

      def trivial?
        results.size < 2
      end

      def results
        results_by_context.values.flatten
      end

      def formatted_label
        "  #{Colorizer.colorize('SORTED OVERVIEW', :normal, :bold, :underline)}"
      end

      def print_header(result, previous_split_context)
        separator = result.context_separator
        split_context = result.context.split(separator)

        formatted_context = formatted_old_and_new(previous_split_context, split_context, separator)

        io.puts(result.formatted_header_prefix + formatted_context)
        split_context
      end

      def print_result_line(result, previous_words)
        prefix = "#{result.formatted_label}#{result.formatted_time}#{result.formatted_number}"
        words = result.name.split(' ')

        formatted_words = formatted_old_and_new(previous_words, words, ' ')

        formatted_message = result.formatted_message
        if formatted_message.empty?
          details = ''
        else
          details = "  #{formatted_message.split("\n").first}"
        end

        io.puts("#{prefix} #{formatted_words}#{details}")
        words
      end

      def formatted_old_and_new(previous, current, separator)
        old_part, new_part = old_and_new(previous, current)

        old_part_string = old_part.join(separator)
        old_part_string << separator unless old_part_string.empty?
        new_part_string = new_part.join(separator)

        formatted_old = Colorizer.colorize(old_part_string, :normal)
        formatted_new = Colorizer.colorize(new_part_string, :normal, :bold)

        "#{formatted_old}#{formatted_new}"
      end

      def old_and_new(previous, current)
        cut_index = first_difference_index(previous, current) || previous.size
        cut_at(current, cut_index)
      end

      def first_difference_index(xs, ys)
        xs.find_index.with_index { |x, i| x != ys[i] }
      end

      def cut_at(xs, i)
        [xs.take(i), xs.drop(i)]
      end

      def print_divider
        io.puts(Colorizer.colorize("  #{'_' * 23}", :normal, :bold))
        io.puts
      end
    end
  end
end

module MinitestBender
  module Sections
    class SortedOverview
      def initialize(io, results_by_context)
        @io = io
        @contexts_with_results = sorted_pairs(results_by_context)
      end

      def print
        return if trivial?

        io.puts(formatted_label)
        io.puts
        previous_context_path = []
        contexts_with_results.each do |context, results|
          io.puts
          print_context(context, previous_context_path)
          previous_context_path = context.path
          words = []
          results.sort_by(&sort_key).each do |result|
            words = print_result(result, words, results)
          end
        end
        io.puts
        print_divider
      end

      private

      attr_reader :io, :contexts_with_results

      def sorted_pairs(results_by_context)
        results_by_context.map do |context, results|
          [context, results.sort_by(&:source_location)]
        end.sort
      end

      def trivial?
        results.size < 2
      end

      def results
        contexts_with_results.map(&:last).flatten
      end

      def formatted_label
        "  #{Colorizer.colorize('SORTED OVERVIEW', :normal, :bold, :underline)}"
      end

      def print_context(result_context, previous_context_path)
        formatted_context = formatted_old_and_new(
          previous_context_path,
          result_context.path,
          result_context.separator
        )

        io.puts(result_context.prefix + formatted_context)
      end

      def sort_key
        @sort_key ||= "#{Minitest::Bender.configuration.overview_sort_key}_sort_key".to_sym
      end

      def print_result(result, previous_words, sorted_siblings)
        formatted_number = result.formatted_number(sorted_siblings)

        prefix = "    #{result.formatted_label_and_time}#{formatted_number}"
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

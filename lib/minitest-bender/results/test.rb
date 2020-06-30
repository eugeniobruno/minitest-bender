module MinitestBender
  module Results
    class Test < Base
      def initialize(minitest_result, raw_name)
        super(minitest_result)
        @raw_name = raw_name
      end

      def formatted_number(sorted_siblings = nil)
        return '' if sorted_siblings.nil?

        number = sorted_siblings.find_index do |result|
          result.source_line_number > source_line_number
        end || sorted_siblings.size
        # this is never 0 because sorted_siblings includes self

        padded_number = number.to_s.rjust(4, '0')

        " #{Colorizer.colorize(padded_number, :number)} "
      end

      def number_sort_key
        source_line_number
      end

      def name
        @name ||= begin
          words = raw_name.split('_')
          words = words.drop(1) if words.first == 'that'
          words.first.capitalize!
          words.last.gsub!(/([a-zA-Z])(\d+)$/, '\1 \2')
          words.join(' ')
        end
      end

      private

      attr_reader :raw_name

      def adjusted_class_name
        class_name.gsub(/^Test|Test$/, '')
      end

      def name_for_rerun_command
        minitest_result.name
      end
    end
  end
end

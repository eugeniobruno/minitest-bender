module MinitestBender
  module Results
    class Test < Base
      def initialize(minitest_result, raw_name)
        super(minitest_result)
        @raw_name = raw_name
      end

      def formatted_number
        '' # not available
      end

      def number_sort_key
        raw_name # because the number is not available
      end

      def name_sort_key
        raw_name
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

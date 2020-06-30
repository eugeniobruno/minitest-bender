module MinitestBender
  module Results
    class Expectation < Base
      attr_reader :name

      def initialize(minitest_result, number, name)
        super(minitest_result)
        @number = number
        @name = name
      end

      def formatted_number(_sorted_siblings = nil)
        " #{Colorizer.colorize(number, :number)} "
      end

      def number_sort_key
        @number_sort_key ||= number.to_i
      end

      private

      attr_reader :number

      def name_for_rerun_command
        "/#{name.gsub(/[^a-zA-Z0-9_\-{}#@]/, '.')}$/"
      end
    end
  end
end

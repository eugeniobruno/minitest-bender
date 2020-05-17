module MinitestBender
  module Results
    class Expectation < Base
      def initialize(minitest_result, number, name)
        super(minitest_result)
        @number = number
        @name = name
      end

      def line_to_report
        "#{formatted_label}#{formatted_time} #{formatted_number} #{name} #{formatted_message}"
      end

      def sort_key
        @sort_key ||= number.to_i
      end

      private

      attr_reader :number, :name

      def formatted_number
        "#{Colorin.brown_400(number)} "
      end

      def name_for_rerun_command
        "/#{name.gsub(' ', '\\ ')}/"
      end
    end
  end
end

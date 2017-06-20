module MinitestBender
  module Results
    class Test < Base
      def initialize(minitest_result, raw_name)
        super(minitest_result)
        @raw_name = raw_name
      end

      def context
        super.gsub(/^Test|Test$/, '')
      end

      def line_to_report
        "#{formatted_label}#{formatted_time} #{name} #{formatted_message}"
      end

      private

      attr_reader :raw_name

      def name
        @name ||= begin
          words = raw_name.split('_')
          words = words.drop(1) if words.first == 'that'
          words.first.capitalize!
          words.last.gsub!(/([a-zA-Z])(\d+)$/, '\1 \2')
          words.join(' ')
        end
      end

      def name_for_rerun_command
        minitest_result.name
      end
    end
  end
end

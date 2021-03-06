# coding: utf-8
# frozen_string_literal: true

module MinitestBender
  module States
    class Skipped < Base
      COLOR = :skip
      LABEL = 'SKIPPED'
      GROUP_LABEL = 'SKIPS'
      ICON = '○'

      def formatted_message(result)
        colored(Utils.first_line(result.failures[0].message))
      end

      def summary_message
        return '' if results.empty?
        skipped_count = results.size
        auxiliary_verb = skipped_count == 1 ? 'was' : 'were'
        colored("#{skipped_count} #{auxiliary_verb} skipped")
      end

      private

      def backtrace(result, padding)
        result.failures[0].message == '(no tests defined)' ? nil : super
      end

      def rerun_line(result, padding)
        result.failures[0].message == '(no tests defined)' ? nil : super
      end
    end
  end
end

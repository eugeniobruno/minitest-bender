# coding: utf-8
# frozen_string_literal: true

module MinitestBender
  module States
    class Failing < Base
      COLOR = :fail
      LABEL = 'FAILED'
      GROUP_LABEL = 'FAILURES'
      ICON = '✖'

      def formatted_message(result)
        colored(location(result))
      end

      def summary_message
        return '' if results.empty?
        colored("#{results.size} failed")
      end
    end
  end
end

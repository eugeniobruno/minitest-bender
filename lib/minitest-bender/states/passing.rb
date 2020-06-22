# coding: utf-8
# frozen_string_literal: true

module MinitestBender
  module States
    class Passing < Base
      COLOR = :pass
      LABEL = 'PASSED'
      GROUP_LABEL = 'PASSING'
      ICON = '✔'

      def formatted_message(_result)
        ''
      end

      def print_details(_io)
        :no_details
      end

      def detail_lines(_result)
        []
      end

      def detail_lines_without_header(_result)
        []
      end

      def summary_message
        return '' if results.empty?
        colored("#{results.size} passed")
      end
    end
  end
end

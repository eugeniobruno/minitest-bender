# coding: utf-8
# frozen_string_literal: true

require 'tty-progressbar'

module MinitestBender
  module Printers
    class WithProgressBar
      COMPLETE_ICON = ' '
      HEAD_ICON = 'ᗧ'
      INCOMPLETE_ICON = '•'
      ELAPSED_ICON = '⏱'
      ETA_ICON = '⌛'

      def initialize(io, total)
        @io = io
        @total = total
        @bar = new_bar
      end

      def print(string)
        io.print(string)
      end

      def print_line(line = '')
        if io.tty?
          bar.log(line)
        else
          io.puts(line)
        end
      end

      def advance
        bar.update({ head: head })
        bar.advance(1, { counters_sym => counters })
      end

      private

      attr_reader :io, :bar, :total

      def new_bar
        TTY::ProgressBar.new(bar_format_string, {
          total: total,
          width: [total, TTY::ProgressBar.max_columns].max,
          complete: complete_icon,
          head: head_icon,
          incomplete: incomplete_icon
        })
      end

      def bar_format_string
        ":bar #{Colorizer.colorize(':current/:total', :tests)}  :#{counters_sym}  #{Colorizer.colorize(elapsed_icon + ' :elapsed', :time)}   #{Colorizer.colorize(eta_icon + ':eta', :time)}  #{Colorizer.colorize(':percent', :normal, :bold)}"
      end

      def counters
        states.map do |state|
          state.colored_icon_with_count(counters_padding_right)
        end.join('  ')
      end

      def counters_sym
        ('c' * counters_sym_length).to_sym
      end

      def counters_sym_length
        ( 4 * (total.to_s.size + 1) ) + 6
      end

      def head
        Colorizer.colorize(head_icon, head_color)
      end

      def complete_icon
        COMPLETE_ICON
      end

      def head_icon
        HEAD_ICON
      end

      def incomplete_icon
        INCOMPLETE_ICON
      end

      def elapsed_icon
        ELAPSED_ICON
      end

      def eta_icon
        ETA_ICON
      end

      def head_color
        reverse_states.find { |s| !s.results.empty? }.color
      end

      def states
        @states ||= MinitestBender.states.values
      end

      def reverse_states
        @reverse_states ||= states.reverse
      end

      def counters_padding_right
        @counters_padding_right ||= total.to_s.size + 1
      end
    end
  end
end

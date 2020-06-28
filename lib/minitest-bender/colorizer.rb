# frozen_string_literal: true

ENV['ANSICON'] ||= 'Y' if ENV['ConEmuANSI'] != 'ON'
require 'paint'

module MinitestBender
  class Colorizer
    COLORS = {              # Xterm No. - Xterm Name
      pass:       '87ff87', # 120       - LightGreen
      fail:       'ff5f5f', # 203       - IndianRed1
      error:      'ffd75f', # 221       - LightGoldenrod2
      skip:       '5fd7ff', # 81        - SteelBlue1
      tests:      '5fafaf', # 73        - CadetBlue
      assertions: 'd75fd7', # 170       - Orchid
      time:       '878787', # 102       - Grey53
      number:     '5fafaf', # 73        - CadetBlue
      backtrace:  'af8787'  # 138       - RosyBrown
    }

    # In compatibility modes, colors that are mapped to black are avoided.
    SAFE_COLORS = {
      pass:       '00ff5f', # 47        - SpringGreen2
      tests:      'blue',
      time:       'gray',
      number:     'gray',
      backtrace:  'gray'
    }
    COLORS.merge!(SAFE_COLORS) if Paint.mode < 256

    COLORS.freeze

    class << self
      def custom_colors=(custom_colors)
        @custom_colors = custom_colors
      end

      def colorize(string, color, *args)
        if color == :normal
          Paint[string, *args]
        else
          color_value = colors.fetch(color)
          Paint[string, color_value, *args]
        end
      end

      def color_keys
        COLORS.keys
      end

      private

      def colors
        @colors ||= COLORS.merge(custom_colors)
      end

      def custom_colors
        @custom_colors || {}
      end
    end
  end
end

require 'rbconfig'

module MinitestBender
  class Colorizer
    FALLBACK_COLORS = {
      red_500: :red,
      green_500: :green,
      amber_300: :yellow,
      blue_a700: :blue,
      purple_400: :magenta,
      cyan_300: :cyan
    }.freeze

    class << self
      def colorize(color, string)
        if fallback?
          fallback_color = FALLBACK_COLORS[color]
          if fallback_color.nil?
            Colorin.new(string)
          else
            Colorin.public_send(fallback_color, string)
          end
        else
          Colorin.public_send(color, string)
        end
      end

      private

      def fallback?
        windows?
      end

      def windows?
        @windows ||= RbConfig::CONFIG['host_os'] =~ /mswin/
      end
    end
  end
end

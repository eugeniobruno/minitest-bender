# frozen_string_literal: true

module MinitestBender
  module Utils
    def self.relative_path(full_path)
      full_path.gsub("#{Dir.pwd}/", '')
    end

    def self.with_home_shorthand(full_path)
      if ENV['HOME'].to_s.start_with?('/home/')
        full_path.sub(ENV['HOME'], '~')
      else
        full_path
      end
    end

    def self.english_join(strings)
      strings.reject(&:empty?).join(', ').gsub(/(.*), /, '\1 and ')
    end

    def self.first_line(string)
      string.split("\n").first.to_s
    end

    def self.with_symbolized_keys(hash)
      hash.each_with_object({}) do |(k, v), h|
        h[k.to_sym] = v
      end
    end

    def self.without_nil_values(hash)
      hash.each_with_object({}) do |(k, v), h|
        h[k] = v unless v.nil?
      end
    end
  end
end

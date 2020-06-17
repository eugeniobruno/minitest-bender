module MinitestBender
  module Utils
    def self.relative_path(full_path)
      full_path.gsub("#{Dir.pwd}/", '')
    end

    def self.english_join(strings)
      strings.reject(&:empty?).join(', ').gsub(/(.*), /, '\1 and ')
    end
  end
end

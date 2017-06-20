module MinitestBender
  module Utils
    def self.relative_path(full_path)
      full_path.gsub("#{Dir.pwd}/", '')
    end
  end
end

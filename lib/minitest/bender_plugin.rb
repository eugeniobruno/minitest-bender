module Minitest
  def self.plugin_bender_init(options)
    Minitest.reporter.reporters.clear
    Minitest.reporter << Bender.new(options.fetch(:io, $stdout), options)
  end

  def self.plugin_bender_options(_opts, _options); end
end

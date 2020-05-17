module Minitest
  def self.plugin_bender_init(options)
    return unless defined? Bender
    Minitest.reporter.reporters.clear
    Minitest.reporter << Bender.new(options.fetch(:io, $stdout), options)
  end

  def self.plugin_bender_options(_opts, _options); end
end

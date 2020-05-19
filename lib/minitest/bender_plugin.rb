require 'minitest/bender'

module Minitest
  def self.plugin_bender_init(options)
    return unless Bender.enabled?
    Minitest.reporter.reporters.clear
    Minitest.reporter << Bender.new(options.fetch(:io, $stdout), options)
  end

  def self.plugin_bender_options(opts, _options)
    opts.on '--bender', 'Use Minitest::Bender test reporter' do
      Bender.enable!
    end

    opts.on '--bender-verbose', 'Use Minitest::Bender test reporter and run each test verbosely' do
      Bender.enable!({ recorder: :verbose })
    end
  end
end

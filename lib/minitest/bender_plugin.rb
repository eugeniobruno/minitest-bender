require 'minitest/bender'

module Minitest
  def self.plugin_bender_init(options)
    return unless Bender.enabled?
    Minitest.reporter.reporters.clear
    Minitest.reporter << Bender.new(options.fetch(:io, $stdout), options)
  end

  def self.plugin_bender_options(opts, _options)
    opts.on '--bender', 'Enable Bender: the coolest CLI reporter.' do
      Bender.enable!
    end

    opts.on '--bender-recorder=RECORDER', 'Bender: choose how test results are printed as the suite runs. (compact | verbose)' do |r|
      Bender.enable!({ recorder: r.to_sym })
    end

    opts.on('--bender-overview', 'Bender: show the overview of sorted results.') do
      Bender.enable!({ overview: :sorted })
    end

    opts.on('--bender-no-overview', 'Bender: skip the overview of sorted results.') do
      Bender.enable!({ overview: :none })
    end

    opts.on '--bender-time-ranking-size=SIZE', 'Bender: adjust the time ranking size.' do |s|
      Bender.enable!({ time_ranking_size: s.to_i })
    end

    opts.on('--bender-backtrace-view=BV', 'Bender: choose the backtrace view for test errors. (user | full)') do |b|
      Bender.enable!({ backtrace_view: b.to_sym })
    end
  end
end

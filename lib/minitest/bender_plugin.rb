require 'minitest/bender'

module Minitest
  def self.plugin_bender_options(opts, _options)
    opts.on '--bender', 'Enable Bender: the coolest CLI reporter.' do
      Bender.enable!
    end

    opts.on '--bender-mode=MODE', 'Bender: choose the mode of interaction with other reporters. (oblivious | cooperative)' do |m|
      Bender.configuration.mode = m
    end

    opts.on '--bender-recorder=RECORDER', 'Bender: choose how test results are printed as the suite runs. (compact | verbose | none)' do |r|
      Bender.configuration.recorder = r
    end

    opts.on('--bender-sections=SECTIONS', 'Bender: choose which sections to print. (comma-separated names)') do |ss|
      Bender.configuration.sections = ss
    end

    opts.on('--bender-sections-blacklist=SECTIONS', 'Bender: choose which sections to skip. (comma-separated names)') do |ss|
      Bender.configuration.sections_blacklist = ss
    end

    opts.on '--bender-overview-sort-key=KEY', 'Bender: choose how tests are sorted in the overview. (name | number)' do |k|
      Bender.configuration.overview_sort_key = k
    end

    opts.on '--bender-time-ranking-size=SIZE', 'Bender: choose the time ranking maximum size.' do |s|
      Bender.configuration.time_ranking_size = s
    end

    opts.on('--bender-backtrace-view=BV', 'Bender: choose the backtrace view for test errors. (user | full)') do |b|
      Bender.configuration.backtrace_view = b
    end

    opts.on('--bender-rerun-command-stem=S', 'Bender: set the stem of rerun commands.') do |s|
      Bender.configuration.rerun_command_stem = s
    end

    MinitestBender::Colorizer.color_keys.each do |color_key|
      opts.on("--bender-#{color_key}-color=COLOR", 'Bender: choose the different colors.') do |c|
        Bender.configuration.set_custom_color(color_key, c)
      end
    end
  end

  def self.plugin_bender_init(options)
    return unless Bender.enabled?
    Minitest.reporter.reporters.clear unless Bender.configuration.cooperative?
    Minitest.reporter << Bender.new(options.fetch(:io, $stdout), options)
  end
end

require 'minitest/bender'

module Minitest
  def self.plugin_bender_options(opts, _options)
    opts.on '--bender', 'Enable Bender: the coolest CLI reporter.' do
      Bender.enable!
    end

    opts.on '--bender-mode MODE', 'Choose the mode of interaction with other reporters. [oblivious | cooperative] (overrides $BENDER_MODE)' do |m|
      Bender.configuration.mode = m
    end

    opts.on '--bender-recorder RECORDER', 'Choose how test results are printed as the suite runs. [progress | progress_groups | progress_issues | progress_groups_and_issues | progress_verbose | icons | grouped_icons | none] (overrides $BENDER_RECORDER)' do |r|
      Bender.configuration.recorder = r
    end

    opts.on('--bender-sections SECTIONS', 'Choose which sections to print. Eg: activity,suite_status (overrides $BENDER_SECTIONS)') do |ss|
      Bender.configuration.sections = ss
    end

    opts.on('--bender-sections-blacklist SECTIONS', 'Choose which sections to skip. Eg: overview,time_ranking (overrides $BENDER_SECTIONS_BLACKLIST)') do |ss|
      Bender.configuration.sections_blacklist = ss
    end

    opts.on '--bender-overview-sort-key KEY', 'Choose how tests are sorted in the overview. [name | number] (overrides $BENDER_OVERVIEW_SORT_KEY)' do |k|
      Bender.configuration.overview_sort_key = k
    end

    opts.on '--bender-time-ranking-size SIZE', 'Set the time ranking maximum size. (overrides $BENDER_TIME_RANKING_SIZE)' do |s|
      Bender.configuration.time_ranking_size = s
    end

    opts.on('--bender-backtrace-view BV', 'Choose the backtrace view for test errors. [user | full] (overrides $BENDER_BACKTRACE_VIEW)') do |b|
      Bender.configuration.backtrace_view = b
    end

    opts.on('--bender-rerun-command-stem STEM', "Set the stem of rerun commands. Eg: 'rake spec' (overrides $BENDER_RERUN_COMMAND_STEM)") do |s|
      Bender.configuration.rerun_command_stem = s
    end

    Bender::Colorizer.color_keys.each do |color_key|
      colorized_color_key = Bender::Colorizer.colorize(color_key.to_s, color_key)
      opts.on("--bender-#{color_key}-color COLOR", "Set the #{colorized_color_key} color. (overrides $BENDER_#{color_key.upcase}_COLOR)") do |c|
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

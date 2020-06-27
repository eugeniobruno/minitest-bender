require 'minitest'
require 'minitest_bender'

module Minitest
  class Bender < AbstractReporter
    Colorizer = MinitestBender::Colorizer

    attr_accessor :io, :options
    attr_reader :previous_context, :results, :results_by_context, :started_at

    class << self
      def enable!(client_config = {})
        @is_enabled = true
        configuration.add_client_config(client_config)
        Colorizer.custom_colors = configuration.custom_colors
      end

      def enabled?
        @is_enabled ||= false
      end

      def configuration
        @configuration ||= MinitestBender::Configuration.new
      end
    end

    def initialize(io, options = {})
      @io = io
      @options = options
      @previous_context = nil
      @results = []
      @results_by_context = {}
      @time_ranking_is_relevant = false
    end

    def start
      @started_at = Time.now
      io.puts
      io.puts Colorizer.colorize("Minitest started at #{started_at}", :normal)
      io.puts Colorizer.colorize("Options: #{options_args}", :normal)
      io.puts
      io.flush
    end

    def record(minitest_result)
      flush_stdio

      result = MinitestBender.result_factory.create(minitest_result)
      results << result

      current_context = result.context

      if current_context != previous_context
        recorder.print_header(result)
        @previous_context = current_context
      end

      (results_by_context[current_context] ||= []) << result

      @time_ranking_is_relevant = true if result.time > 0.01

      recorder.print_content(result)
      io.flush
    end

    def passed?
      passed_count + skipped_count == test_count
    end

    def report
      if results.empty?
        print_no_tests_status
        return
      end

      io.puts
      io.puts
      print_divider(:normal)

      sections.each(&:print)
    end

    private

    def configuration
      self.class.configuration
    end

    def flush_stdio
      # as we might already have some output from the test itself,
      # make sure we see *all* of it before we report anything
      STDOUT.flush
      STDERR.flush
    end

    def options_args
      options.fetch(:args, '(none)')
    end

    def recorder
      @recorder ||= begin
        recorder_sym = configuration.recorder
        case recorder_sym
        when :compact
          MinitestBender::Recorders::Compact.new(io)
        when :verbose
          MinitestBender::Recorders::Verbose.new(io)
        when :none
          MinitestBender::Recorders::None.new
        else
          raise "unknown recorder: #{recorder_sym}"
        end
      end
    end

    def passed_count
      @passed_count ||= results.count(&:passed?)
    end

    def skipped_count
      @skipped_count ||= results.count(&:skipped?)
    end

    def test_count
      results.size
    end

    def print_divider(color, line_length = 23)
      io.puts(Colorizer.colorize("  #{'_' * line_length}", color, :bold))
      io.puts
    end

    def print_no_tests_status
      message = 'NO TESTS WERE RUN!  (-_-)zzz'
      padded_message = "  #{message}"
      io.puts(Colorizer.colorize(padded_message, :tests))
      print_divider(:tests, message.length)
    end

    def time_ranking_size
      if @time_ranking_is_relevant
        configuration.time_ranking_size
      else
        0
      end
    end

    def sections
      section_names.map do |section_name|
        case section_name
        when :overview
          MinitestBender::Sections::SortedOverview.new(io, results_by_context)
        when :time_ranking
          MinitestBender::Sections::TimeRanking.new(io, time_ranking_size, results)
        when :issues
          MinitestBender::Sections::Issues.new(io)
        when :activity
          MinitestBender::Sections::Activity.new(io, started_at, results)
        when :suite_status
          MinitestBender::Sections::SuiteStatus.new(io, options_args, results)
        else
          raise "unknown section: #{section_name}"
        end
      end
    end

    def section_names
      configuration.sections
    end
  end

  ##
  # Compatibility with
  # [minitest-reporters](https://github.com/kern/minitest-reporters)
  #
  # Given:
  #
  # ```
  # require 'minitest/reporters'
  # Minitest::Reporters.use!
  # ```
  #
  # Bender can be selected with:
  #
  # ```
  # MINITEST_REPORTER=BenderReporter rake test
  # ```

  module Reporters
    class BenderReporter < Minitest::Bender
      def initialize(options = {})
        super(options.fetch(:io, $stdout), options)
        Minitest::Bender.enable!
      end

      def add_defaults(defaults)
        @options = defaults.merge(options)
      end

      def before_test(_test_cls); end

      def after_test(_test_cls); end
    end
  end
end

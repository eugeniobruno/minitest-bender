require 'minitest'
require 'minitest_bender'

module Minitest
  class Bender < AbstractReporter
    Colorizer = MinitestBender::Colorizer

    @@reporter_options = {
      recorder: :compact,
      overview: :sorted,
      time_ranking_size: 5,
      backtrace_view: :user
    }

    attr_accessor :io, :options
    attr_reader :previous_context, :results, :results_by_context, :started_at

    def self.enable!(reporter_options = {})
      @@is_enabled = true
      @@reporter_options.merge!(reporter_options)
    end

    def self.enabled?
      @@is_enabled ||= false
    end

    def initialize(io, options = {})
      @io = io
      @options = options
      @previous_context = nil
      @results = []
      @results_by_context = {}
      @time_ranking_is_relevant = false
      MinitestBender.backtrace_view = @@reporter_options.fetch(:backtrace_view).to_sym
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
        io.puts
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
        recorder_sym = @@reporter_options.fetch(:recorder)
        case recorder_sym
        when :compact
          MinitestBender::Recorders::Compact.new(io)
        when :verbose
          MinitestBender::Recorders::Verbose.new(io)
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

    def sorted_overview_enabled?
      @@reporter_options.fetch(:overview) == :sorted
    end

    def must_print_time_ranking?
      @time_ranking_is_relevant
    end

    def time_ranking_size
      @@reporter_options.fetch(:time_ranking_size)
    end

    def sections
      [
        sorted_overview_section,
        time_ranking_section,
        issues_section,
        activity_section,
        suite_status_section
      ].flatten(1)
    end

    def sorted_overview_section
      if sorted_overview_enabled?
        MinitestBender::Sections::SortedOverview.new(io, results_by_context)
      else
        MinitestBender::Sections::Silence.new
      end
    end

    def time_ranking_section
      if must_print_time_ranking?
        MinitestBender::Sections::TimeRanking.new(io, time_ranking_size, results)
      else
        MinitestBender::Sections::Silence.new
      end
    end

    def issues_section
      MinitestBender::Sections::Issues.new(io)
    end

    def activity_section
      MinitestBender::Sections::Activity.new(io, started_at, results)
    end

    def suite_status_section
      MinitestBender::Sections::SuiteStatus.new(io, options_args, results)
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

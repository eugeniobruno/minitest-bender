require 'minitest'
require 'minitest_bender'

module Minitest
  class Bender < AbstractReporter
    Colorizer = MinitestBender::Colorizer

    @@reporter_options = {
      recorder: :compact,
      overview: :sorted
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
      @slowness_podium_is_relevant = false
    end

    def start
      @started_at = Time.now
      io.puts
      io.puts Colorizer.colorize(:white, "Minitest started at #{started_at}")
      io.puts Colorizer.colorize(:white, "Options: #{options_args}")
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

        if verbose_recorder?
          io.puts(result.header)
        else
          io.print("#{result.header} ")
        end

        @previous_context = current_context
      end

      (results_by_context[current_context] ||= []) << result

      @slowness_podium_is_relevant = true if result.time > 0.01

      if verbose_recorder?
        print_verbose_result(result)
      else
        io.print result.to_icon
      end
      io.flush
    end

    def flush_stdio
      # as we might already have some output from the test itself,
      # make sure we see *all* of it before we report anything
      STDOUT.flush
      STDERR.flush
    end

    def passed?
      passed_count + skipped_count == test_count
    end

    def report
      io.puts
      io.puts
      print_divider(:white)

      if sorted_overview_enabled? && results.size > 1
        print_sorted_overview
      end

      print_details

      if @slowness_podium_is_relevant && passed?
        print_slowness_podium
        io.puts
      end

      print_statistics
      io.puts

      print_suite_status
    end

    private

    def options_args
      options.fetch(:args, '(none)')
    end

    def verbose_recorder?
      @@reporter_options.fetch(:recorder) == :verbose
    end

    def sorted_overview_enabled?
      @@reporter_options.fetch(:overview) == :sorted
    end

    def passed_without_skips?
      passed_count == test_count
    end

    def run_all_tests?
      !options_args.include?('--name')
    end

    def test_count
      results.size
    end

    def passed_count
      @passed_count ||= results.count(&:passed?)
    end

    def skipped_count
      @skipped_count ||= results.count(&:skipped?)
    end

    def assertion_count
      @assertion_count ||= results.reduce(0) { |acum, result| acum + result.assertions }
    end

    def print_divider(color)
      io.puts(Colorizer.colorize(color, '  _______________________').bold)
      io.puts
    end

    def print_sorted_overview
      io.puts(formatted_label(:white, 'SORTED OVERVIEW'))
      io.puts
      results_by_context.sort.each do |context, results|
        io.puts
        io.puts(results.first.header)
        results.sort_by(&:sort_key).each do |result|
          io.puts result.line_to_report
        end
      end
      io.puts
      print_divider(:white)
    end

    def print_details
      states = MinitestBender.states.values
      symbols = states.map { |state| state.print_details(io, results) }
      io.puts unless symbols.all? { |symbol| symbol == :no_details }
    end

    def print_verbose_result(result)
      io.puts result.line_to_report
      result.state.print_detail(io, result) unless result.passed?
    end

    def print_statistics
      total_tests = "#{test_count} tests"
      total_tests = total_tests.chop if test_count == 1
      formatted_total_tests = Colorizer.colorize(:blue_a700, total_tests)

      total_assertions = "#{assertion_count} assertions"
      total_assertions = total_assertions.chop if assertion_count == 1
      formatted_total_assertions = Colorizer.colorize(:purple_400, total_assertions)

      auxiliary_verb = test_count == 1 ? 'was' : 'were'

      total_time = (Time.now - started_at).round(3)
      formatted_total_time = Colorizer.colorize(:grey_700, "#{total_time} seconds")

      tests_rate = Colorizer.colorize(:grey_700, "#{(test_count / total_time).round(4)} tests/s")
      assertions_rate = Colorizer.colorize(:grey_700, "#{(assertion_count / total_time).round(4)} assertions/s")

      io.puts "  #{formatted_total_tests} with #{formatted_total_assertions} #{auxiliary_verb} run in #{formatted_total_time} (#{tests_rate}, #{assertions_rate})"
    end

    def print_suite_status
      all_passed_color = MinitestBender.passing_color
      final_divider_color = all_passed_color

      if passed_without_skips? && run_all_tests?
        message = Colorizer.colorize(all_passed_color, '  ALL TESTS PASS!  (^_^)/')
      else
        messages = MinitestBender.states.values.map do |state|
          summary_message = state.summary_message(results)
          final_divider_color = state.color unless summary_message.empty?
          summary_message
        end

        message = "  #{messages.reject(&:empty?).join(', ').gsub(/(.*), /, '\1 and ')}"
      end
      io.puts(message)

      print_divider(final_divider_color)
    end

    def print_slowness_podium
      results.sort_by! { |r| -r.time }

      io.puts(formatted_label(:grey_700, 'SLOWNESS PODIUM'))
      io.puts
      results.take(3).each_with_index do |result, i|
        number = "#{i + 1})".ljust(4)
        io.puts "    #{number}#{result.line_for_slowness_podium}"
      end
    end

    def formatted_label(color, label)
      "  #{Colorizer.colorize(color, label).bold.underline}"
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

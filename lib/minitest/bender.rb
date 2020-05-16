require 'minitest'
require 'minitest_bender'

module Minitest
  class Bender < AbstractReporter
    attr_reader :io, :options, :previous_context, :results, :started_at

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
      io.puts Colorin.white("Minitest started at #{started_at}")
      io.puts Colorin.white("Options: #{options_args}")
      io.puts
    end

    def record(minitest_result)
      result = MinitestBender.result_factory.create(minitest_result)
      results << result

      current_context = result.context

      if current_context != previous_context
        io.puts
        io.print(result.header + ' ')
        @previous_context = current_context
      end
      (@results_by_context[current_context] ||= []) << result

      @slowness_podium_is_relevant = true if result.time > 0.01

      io.print result.compact
    end

    def passed?
      passed_count + skipped_count == test_count
    end

    def report
      io.puts
      io.puts
      print_divider(:white)

      @results_by_context.keys.sort.each do |context|
        results = @results_by_context[context]
        io.puts
        io.puts(results.first.header)
        results.sort_by(&:rank).each { |result| io.puts result.line_to_report }
      end

      io.puts
      print_divider(:white)

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
      io.puts(Colorin.public_send(color, '  _______________________').bold)
      io.puts
    end

    def print_details
      states = MinitestBender.states.values
      symbols = states.map { |state| state.print_details(io, results) }
      io.puts unless symbols.all? { |symbol| symbol == :no_details }
    end

    def print_statistics
      total_tests = "#{test_count} tests"
      total_tests = total_tests.chop if test_count == 1
      formatted_total_tests = Colorin.blue_a700(total_tests)

      total_assertions = "#{assertion_count} assertions"
      total_assertions = total_assertions.chop if assertion_count == 1
      formatted_total_assertions = Colorin.purple_400(total_assertions)

      auxiliary_verb = test_count == 1 ? 'was' : 'were'

      total_time = (Time.now - started_at).round(3)
      formatted_total_time = Colorin.grey_700("#{total_time} seconds")

      tests_rate = Colorin.grey_700("#{(test_count / total_time).round(4)} tests/s")
      assertions_rate = Colorin.grey_700("#{(assertion_count / total_time).round(4)} assertions/s")

      io.puts "  #{formatted_total_tests} with #{formatted_total_assertions} #{auxiliary_verb} run in #{formatted_total_time} (#{tests_rate}, #{assertions_rate})"
    end

    def print_suite_status
      all_passed_color = MinitestBender.passing_color
      final_divider_color = all_passed_color

      if passed_without_skips? && run_all_tests?
        message = Colorin.public_send(all_passed_color, '  ALL TESTS PASS!  (^_^)/')
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

      io.puts(formatted_slowness_podium_label)
      io.puts
      results.take(3).each_with_index do |result, i|
        number = "#{i + 1})".ljust(4)
        io.puts "    #{number}#{result.line_for_slowness_podium}"
      end
    end

    def formatted_slowness_podium_label
      "  #{Colorin.grey_700('SLOWNESS PODIUM').bold.underline}"
    end
  end
end

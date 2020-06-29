module MinitestBender
  class Configuration
    DEFAULT_CONFIG = {
      mode: :oblivious,
      recorder: :compact,
      sections: [:overview, :time_ranking, :issues, :activity, :suite_status],
      sections_blacklist: [],
      overview_sort_key: :name,
      time_ranking_size: 5,
      backtrace_view: :user,
      run_command: defined?(Rake) ? 'rake' : 'ruby',
      custom_colors: {}
    }.freeze

    def initialize
      @client_config = {}
      @options_config = {}
    end

    def add_client_config(config)
      client_config.merge!(config)
    end

    def mode=(mode)
      options_config[:mode] = mode
    end

    def recorder=(recorder)
      options_config[:recorder] = recorder
    end

    def sections=(sections)
      options_config[:sections] = sections
    end

    def sections_blacklist=(sections_blacklist)
      options_config[:sections_blacklist] = sections_blacklist
    end

    def overview_sort_key=(overview_sort_key)
      options_config[:overview_sort_key] = overview_sort_key
    end

    def time_ranking_size=(time_ranking_size)
      options_config[:time_ranking_size] = time_ranking_size
    end

    def backtrace_view=(backtrace_view)
      options_config[:backtrace_view] = backtrace_view
    end

    def run_command=(run_command)
      options_config[:run_command] = run_command
    end

    def set_custom_color(color_key, color)
      options_config[:custom_colors] ||= {}
      options_config[:custom_colors][color_key] = color
    end

    def cooperative?
      final_config.fetch(:mode) == :cooperative
    end

    def recorder
      final_config.fetch(:recorder)
    end

    def sections
      sections_whitelist - sections_blacklist
    end

    def overview_sort_key
      final_config.fetch(:overview_sort_key)
    end

    def time_ranking_size
      final_config.fetch(:time_ranking_size)
    end

    def backtrace_view
      final_config.fetch(:backtrace_view)
    end

    def run_command
      final_config.fetch(:run_command)
    end

    def custom_colors
      final_config.fetch(:custom_colors)
    end

    private

    attr_reader :client_config, :options_config

    def parsed_list(list)
      strings = list.is_a?(Array) ? list.map(&:to_s) : list.split(',')
      strings.map { |s| s.strip.to_sym }
    end

    def default_config
      DEFAULT_CONFIG
    end

    def env_config
      {
        mode: ENV['MINITEST_BENDER_MODE'],
        recorder: ENV['MINITEST_BENDER_RECORDER'],
        sections: ENV['MINITEST_BENDER_SECTIONS'],
        sections_blacklist: ENV['MINITEST_BENDER_SECTIONS_BLACKLIST'],
        overview_sort_key: ENV['MINITEST_BENDER_OVERVIEW_SORT_KEY'],
        time_ranking_size: ENV['MINITEST_BENDER_TIME_RANKING_SIZE'],
        backtrace_view: ENV['MINITEST_BENDER_BACKTRACE_VIEW'],
        run_command: ENV['MINITEST_BENDER_RUN_COMMAND'],
        custom_colors: custom_colors_env_config
      }
    end

    def custom_colors_env_config
      Colorizer.color_keys.each_with_object({}) do |color_key, h|
        h[color_key] = ENV["MINITEST_BENDER_#{color_key.upcase}_COLOR"]
      end
    end

    def merged_config
      [default_config, client_config, env_config, options_config].reduce do |acum, config|
        proper_config = Utils.with_symbolized_keys(Utils.without_nil_values(config))
        acum.merge(proper_config) do |key, old_val, new_val|
          if key == :custom_colors
            old_val.merge(Utils.with_symbolized_keys(Utils.without_nil_values(new_val)))
          else
            new_val
          end
        end
      end
    end

    def final_config
      merged_config.tap do |config|
        config[:mode] = config[:mode].to_sym
        config[:recorder] = config[:recorder].to_sym
        config[:sections] = parsed_list(config[:sections])
        config[:sections_blacklist] = parsed_list(config[:sections_blacklist])
        config[:overview_sort_key] = config[:overview_sort_key].to_sym
        config[:time_ranking_size] = config[:time_ranking_size].to_i
        config[:run_command] = config[:run_command].to_s
        config[:backtrace_view] = config[:backtrace_view].to_sym
      end
    end

    def sections_whitelist
      final_config.fetch(:sections)
    end

    def sections_blacklist
      final_config.fetch(:sections_blacklist)
    end
  end
end

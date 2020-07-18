module MinitestBender
  class Configuration
    DEFAULT_CONFIG = {
      mode: :oblivious,
      recorder: :progress,
      sections: [:overview, :time_ranking, :issues, :activity, :suite_status],
      sections_blacklist: [],
      overview_sort_key: :name,
      time_ranking_size: 5,
      backtrace_view: :user,
      rerun_command_stem: defined?(Rake) ? 'rake' : 'ruby',
      custom_colors: {}
    }.freeze

    def initialize
      @client_config = {}
      @options_config = {}
    end

    def add_client_config(config)
      validate_config(config)
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

    def rerun_command_stem=(rerun_command_stem)
      options_config[:rerun_command_stem] = rerun_command_stem
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

    def rerun_command_stem
      final_config.fetch(:rerun_command_stem)
    end

    def custom_colors
      final_config.fetch(:custom_colors)
    end

    private

    attr_reader :client_config, :options_config

    def validate_config(config)
      invalid_options = config.keys.map(&:to_sym) - valid_options
      unless invalid_options.empty?
        first_invalid_option = invalid_options.first
        message = "invalid option: '#{first_invalid_option}'"
        raise ArgumentError, message
      end
    end

    def valid_options
      default_config.keys
    end

    def parsed_list(list)
      strings = list.is_a?(Array) ? list.map(&:to_s) : list.split(',')
      strings.map { |s| s.strip.to_sym }
    end

    def default_config
      DEFAULT_CONFIG
    end

    def env_config
      {
        mode: ENV['BENDER_MODE'],
        recorder: ENV['BENDER_RECORDER'],
        sections: ENV['BENDER_SECTIONS'],
        sections_blacklist: ENV['BENDER_SECTIONS_BLACKLIST'],
        overview_sort_key: ENV['BENDER_OVERVIEW_SORT_KEY'],
        time_ranking_size: ENV['BENDER_TIME_RANKING_SIZE'],
        backtrace_view: ENV['BENDER_BACKTRACE_VIEW'],
        rerun_command_stem: ENV['BENDER_RERUN_COMMAND_STEM'],
        custom_colors: custom_colors_env_config
      }
    end

    def custom_colors_env_config
      Colorizer.color_keys.each_with_object({}) do |color_key, h|
        h[color_key] = ENV["BENDER_#{color_key.upcase}_COLOR"]
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
        config[:rerun_command_stem] = config[:rerun_command_stem].to_s
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

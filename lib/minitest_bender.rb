# frozen_string_literal: true

require 'minitest-bender/version'

require 'minitest-bender/configuration'
require 'minitest-bender/colorizer'

require 'minitest-bender/states/base'
require 'minitest-bender/states/passing'
require 'minitest-bender/states/skipped'
require 'minitest-bender/states/failing'
require 'minitest-bender/states/raising'

require 'minitest-bender/results/base'
require 'minitest-bender/results/test'
require 'minitest-bender/results/expectation'

require 'minitest-bender/recorders/compact'
require 'minitest-bender/recorders/verbose'
require 'minitest-bender/recorders/none'

require 'minitest-bender/sections/sorted_overview'
require 'minitest-bender/sections/time_ranking'
require 'minitest-bender/sections/issues'
require 'minitest-bender/sections/activity'
require 'minitest-bender/sections/suite_status'

require 'minitest-bender/result_factory'
require 'minitest-bender/utils'

module MinitestBender
  STATES = {
    '.' => States::Passing.new,
    'S' => States::Skipped.new,
    'F' => States::Failing.new,
    'E' => States::Raising.new
  }.freeze

  def self.states
    STATES
  end

  def self.result_factory
    @result_factory ||= ResultFactory.new
  end

  def self.passing_color
    states.fetch('.').color
  end
end

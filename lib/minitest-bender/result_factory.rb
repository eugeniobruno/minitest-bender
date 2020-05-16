module MinitestBender
  class ResultFactory
    RESULT_NAME_REGEXP = /test_(?<number>\d*)_?(?<name>.+)?/
    ANONYMOUS = 'anonymous'.freeze

    def create(minitest_result)
      result_number = number(minitest_result)
      result_name = name(minitest_result)
      if result_number.empty?
        Results::Test.new(minitest_result, result_name, result_name)
      else
        Results::Expectation.new(minitest_result, result_number, result_name)
      end
    end

    private

    attr_reader :minitest_result

    def number(minitest_result)
      parsed_name(minitest_result)[:number]
    end

    def name(minitest_result)
      (parsed_name(minitest_result)[:name] || ANONYMOUS).strip
    end

    def parsed_name(minitest_result)
      minitest_result.name.match(RESULT_NAME_REGEXP)
    end
  end
end

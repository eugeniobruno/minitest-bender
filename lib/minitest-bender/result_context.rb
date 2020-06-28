# coding: utf-8
# frozen_string_literal: true

module MinitestBender
  class ResultContext < String
    PREFIX = '• '
    SEPARATOR = ' ▸ '
    CLASS_SEPARATOR = '::'

    def initialize(class_name)
      @class_name = class_name
      super(path.join(separator))
    end

    def path
      class_name.split(class_separator)
    end

    def with_prefix
      prefix + self
    end

    def separator
      SEPARATOR
    end

    def prefix
      PREFIX
    end

    private

    attr_reader :class_name

    def class_separator
      CLASS_SEPARATOR
    end
  end
end

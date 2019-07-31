module Extractors
  class BaseExtractor
    def initialize(holiday_expr, period)
      @holiday_expr = holiday_expr
      @period       = period
    end

    def call
      raise NotImplementedError
    end

    private

    attr_reader :holiday_expr, :period
  end
end
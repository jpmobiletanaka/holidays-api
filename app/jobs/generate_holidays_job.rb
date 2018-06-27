class GenerateHolidaysJob < ApplicationJob
  queue_as :generate_holidays

  def perform(holiday_expr_id)
    HolidayExpr.find(holiday_expr_id).generate_holidays
  end
end

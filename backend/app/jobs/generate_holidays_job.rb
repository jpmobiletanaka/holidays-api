class GenerateHolidaysJob < ApplicationJob
  queue_as :generate_holidays

  def perform(holiday_expr_id, params = {})
    holiday_expr = HolidayExpr.find(holiday_expr_id)
    return if holiday_expr.processed?

    Generators::Manual::GenerateHolidays.new(holiday_expr, params).call
  end
end

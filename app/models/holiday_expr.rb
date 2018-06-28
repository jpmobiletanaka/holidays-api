class HolidayExpr < ApplicationRecord
  DAY                = /[0-3]{0,1}\d{1}/
  MONTH              = /[0-1]{0,1}\d{1}/
  YEAR               = /[1-2]+\d{3}/
  ADD                = /\((\+)(\d{1,2})\)/
  SIMPLE_GROUP       = %r{^((#{YEAR})(\.|\/))?(#{MONTH})(\.|\/)(#{DAY})$}
  NTH_DAY_GROUP      = %r{^((#{YEAR})(\.|\/))?(#{MONTH})(\.|\/)((-?[1-4]{1})(\,)([1-7]{1}))(#{ADD})?$}
  PERIOD_GROUP       = %r{^((#{YEAR})(\.|\/))?(#{MONTH})(\.|\/)(#{DAY})-(#{DAY})$}
  LARGE_PERIOD_GROUP = %r{^((#{YEAR})(\.|\/))?(\((#{MONTH})(\.|\/)(#{DAY})\))-(\((#{MONTH})(\.|\/)(#{DAY})\))$}
  MOON_GROUP         = %r{^((#{YEAR})(\.|\/))?(#{MONTH})(\.|\/)(full.*moon)(#{ADD})?$}
  EXPRESSION_REGEXP  = /(#{SIMPLE_GROUP})|(#{NTH_DAY_GROUP})|(#{LARGE_PERIOD_GROUP})|(#{PERIOD_GROUP})|(#{MOON_GROUP})/

  enum calendar_type: %i[gregorian julian]
  enum holiday_type:  %i[holiday]

  scope :processed,   -> { where(processed: true) }
  scope :unprocessed, -> { where(processed: false) }

  has_many :holidays
  belongs_to :country, primary_key: :country_code, foreign_key: :country_code

  validate :valid_expression?

  def processed!
    update!(processed: true)
  end

  def with_year?
    expression.match?(/^#{YEAR}/)
  end

  def generate_holidays(params = {})
    return false if processed?
    HolidayGenerateService.new(self, params).call
  end

  private

  def valid_expression?
    return if expression.match?(EXPRESSION_REGEXP)
    errors.add(:expression, 'is invalid')
  end
end

# 2018/(12/31)-(06/01)
class HolidayExpr < ApplicationRecord
  # rubocop:disable Metrics/LineLength
  DAY                 = /0?[1-2]?\d{1}|3[0-1]/.freeze
  MONTH               = /0?[1-9]|1[0-2]/.freeze
  YEAR                = /\(?[1-2]+\d{3}/.freeze
  ADD                 = /\((\+)(\d{1,2})\)/.freeze
  SIMPLE_GROUP        = %r{^((#{YEAR})(\.|/))?(#{MONTH})(\.|/)(#{DAY})$}.freeze
  NTH_DAY_GROUP       = %r{^((#{YEAR})(\.|/))?(#{MONTH})(\.|/)((-?[1-4]{1})(,)([1-7]{1}))(#{ADD})?$}.freeze
  PERIOD_GROUP        = %r{^((#{YEAR})(\.|/))?(#{MONTH})(\.|/)(#{DAY})-(#{DAY})$}.freeze
  LARGE_PERIOD_GROUP  = %r{^((#{YEAR})(\.|/))?(\((#{MONTH})(\.|/)(#{DAY})\))-(\((#{MONTH})(\.|/)(#{DAY})\))$}.freeze
  XLARGE_PERIOD_GROUP = %r{^(\(?(#{YEAR})(\.|/)(#{MONTH})(\.|/)(#{DAY})\)?)-(\(?(#{YEAR})(\.|/)(#{MONTH})(\.|/)(#{DAY})\)?)$}.freeze
  MOON_GROUP          = %r{^((#{YEAR})(\.|/))?(#{MONTH})(\.|/)(full.*moon)(#{ADD})?$}.freeze
  EXPRESSION_REGEX    = /(#{SIMPLE_GROUP})|(#{NTH_DAY_GROUP})|(#{LARGE_PERIOD_GROUP})|(#{XLARGE_PERIOD_GROUP})|(#{PERIOD_GROUP})|(#{MOON_GROUP})/mix.freeze
  # rubocop:enable Metrics/LineLength

  enum calendar_type: { gregorian: 0, julian: 1 }
  enum holiday_type:  { holiday: 0 }

  scope :unprocessed, -> { where(processed: false) }

  has_many :holidays
  has_many :history_records, class_name: 'HolidayExprHistory'
  has_many :days, through: :holidays
  belongs_to :country, primary_key: :country_code, foreign_key: :country_code

  validate :valid_expression?
  validates :ja_name, uniqueness: { scope: %i[en_name country_code expression],
                                    message: "with same country and dates has already been taken" }

  after_commit :generate_holidays, on: %i[create update]

  def processed!
    update!(processed: true)
  end

  def with_year?
    expression.match?(/^#{YEAR}/)
  end

  def recurring?
    !with_year?
  end

  def generate_holidays(params = {})
    return false if processed?

    GenerateHolidaysJob.perform_later(id, params)
  end

  private

  def valid_expression?
    return if expression.match?(EXPRESSION_REGEX)

    errors.add(:expression, 'is invalid')
  end
end

class MergeEventGroupService < BaseService
  def initialize(events:)
    @events = events
  end

  def call
    chunked_events(events).map do |events_chunk|
      expression = expression_from_dates(events_chunk.map { |event| event.delete(:date_hash) })
      event = events_chunk.inject(&:merge)
      event[:expression] = expression
      event
    end
  end

  private

  attr_reader :events

  def expression_from_dates(dates)
    return [dates[0][:year], dates[0][:month], dates[0][:day]].join('.') if dates.size == 1
    expression = if same_month?(dates[0], dates[-1])
                   [dates[0][:year], dates[0][:month], "#{dates[0][:day]}-#{dates[-1][:day]}"].join('.')
                 else
                   ["#{dates[0][:year]}.(#{dates[0][:month]}.#{dates[0][:day]})",
                    "(#{dates[-1][:month]}.#{dates[-1][:day]})"].join('-')
                 end
    Rails.logger.info expression
    expression
  end

  def chunked_events(events)
    events.chunk_while { |before, after| count_diff(before[:date_hash], after[:date_hash]) }
  end

  def count_diff(before, after)
    after_arr = [after[:year], after[:month], after[:day]].map(&:to_i)
    before_arr = [before[:year], before[:month], before[:day]].map(&:to_i)
    Date.new(*after_arr).beginning_of_day - Date.new(*before_arr).beginning_of_day <= 86_400
  end

  def same_month?(start_date, end_date)
    same_year?(start_date, end_date) && start_date[:month] == end_date[:month]
  end

  def same_year?(start_date, end_date)
    start_date[:year] == end_date[:year]
  end

  # Not supported yet
  # def extended_expression(date_hash, with_year = false)
  #   (with_year ? date_hash : date_hash.slice(:month, :day)).values.join('.')
  # end
end

class MergeEventGroupService < BaseService
  def initialize(events:)
    @events = events
  end

  def call
    chunked_events(events).map do |events_chunk|
      expression = expression_from_dates(events_chunk.map { |event| event.delete(:date_hash) })
      event = events_chunk.inject(&:merge)
      event[:expression] = expression
      event.delete(:weight)
      event
    end
  end

  private

  attr_reader :events

  def expression_from_dates(dates)
    return dates[0].values.join('.') if dates.size == 1
    expression = if same_month?(dates[0], dates[-1])
                   [dates[0][:year], dates[0][:month], "#{dates[0][:day]}-#{dates[-1][:day]}"].join('.')
                 else
                   "(#{extended_expression(dates[0], :with_year)})-(#{extended_expression(dates[-1], :with_year)})"
                 end
    Rails.logger.info expression
    expression
  end
  
  def chunked_events(events)
    events.map { |event| event.merge(weight: count_weight(event[:date_hash])) }
          .chunk_while { |before, after| before[:weight] + 10 == after[:weight] }
  end

  def count_weight(date_hash)
    date_hash.values.reverse.each_with_index.map{|e, i| e.to_i * (10**(i+1))}.sum
  end

  def same_month?(start_date, end_date)
    same_year?(start_date, end_date) && start_date[:month] == end_date[:month]
  end

  def same_year?(start_date, end_date)
    start_date[:year] == end_date[:year]
  end
  
  def extended_expression(date_hash, with_year = false)
    (with_year ? date_hash : date_hash.slice(:month, :day)).values.join('.')
  end
end

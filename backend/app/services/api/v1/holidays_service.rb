# frozen-string-literal: true

module Api
  module V1
    class HolidaysService
      HOLIDAY_ATTRS = %w[id country_code ja_name en_name observed day_off current_source_type
                        holiday_expr_id updated_at created_at].freeze
      DELETE_EVENT = 'DELETE'.freeze

      def initialize(params)
        @params = params
      end

      def call
        scope.group_by(&holiday_rel).map do |holiday, days|
          holiday.slice(*select_attrs).merge(
            dates: days.select(&:enabled?).map(&:date).sort,
            # moves: moves(days),
            destroyed: holiday.respond_to?(:holiday) && holiday.holiday.nil?,
            recurring: holiday.recurring? || false
          ).symbolize_keys
        end
      end

      private

      def select_attrs
        return HOLIDAY_ATTRS unless history_request?
        ['holiday_id', *HOLIDAY_ATTRS]
      end

      def holiday_rel
        @_holiday_rel ||= history_request? ? :holiday_history : :holiday
      end

      def history_request?
        @_history_request ||= state_date.present?
      end

      attr_reader :params

      def moves(days)
        days.map! do |day|
          next if day.enabled?
          { from: day.date, to: day.moved_to_date }
        end.compact!
      end

      def state_date
        @_state_date ||= params[:state_at]&.to_date
      end

      def base_year
        @_base_year ||= params[:year]&.to_i || state_date&.year || Date.current.year
      end

      def date_from
        @_date_from ||= params[:from]&.to_date || Date.civil(base_year, 1, 1)
      end

      def date_to
        @_date_to ||= params[:to]&.to_date || Date.civil(base_year, 12, 31)
      end

      def scope
        where_option = {}
        where_option = { holidays: { country_code: country_codes } } if country_codes.present?
        return history_holidays if history_request?
        @_scope ||= Day.by_date(date_from..date_to)
                      .joins(:holiday)
                      .includes({ holiday: :holiday_expr }, :moved_to)
                      .where(where_option)
                      .order(:date, :holiday_id)
      end

      def partition_query(deleted_only: false)
        query = HolidayHistory
                .select(:holiday_id,
                        'row_number() OVER (PARTITION BY holiday_id ORDER BY date DESC) AS ts_position')
                .where("date <= ?::date", state_date)
        query = query.where(country_code: country_codes) if country_codes.present?
        query = query.where(event: DELETE_EVENT) if deleted_only
        query
      end

      def history_holidays
        deleted_holiday_ids = partition_query(deleted_only: true).pluck(:holiday_id)
        @scope ||= Day.by_date(date_from..date_to)
                      .joins("INNER JOIN (#{partition_query.to_sql}) t USING(holiday_id)")
                      .includes(:moved_to, holiday_history: { holiday: :holiday_expr })
                      .where("t.ts_position <= ?", 1)
                      .where.not(holiday_id: deleted_holiday_ids)
      end

      def country_codes
        params[:country_code].presence || params[:country_codes].presence
      end
    end
  end
end

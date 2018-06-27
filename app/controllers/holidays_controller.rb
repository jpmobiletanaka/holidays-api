class HolidaysController < ApplicationController
  before_action :scope

  def index
    render_response { holidays }
  end

  private

  def holidays
    @scope.group(:ja_name, :country_code, Arel.sql('YEAR(date)'))
          .order(Arel.sql('YEAR(date)'), :country_code)
          .pluck(:ja_name, :country_code, Arel.sql('ANY_VALUE(en_name)'), Arel.sql('GROUP_CONCAT(date)'))
          .map do |ja_name, country_code, en_name, dates|
            { country_code: country_code, ja_name: ja_name, en_name: en_name, dates: dates.split(',') }
          end
  end

  def scope
    base_year    = params[:year]&.to_i    || Date.current.year
    date_from    = params[:from]&.to_date || Date.civil(base_year, 1, 1)
    date_to      = params[:to]&.to_date   || Date.civil(base_year, 12, 31)
    country_code = params[:country_code]
    @scope       = Holiday.by_date(date_from..date_to).by_country_code(country_code)
  end
end

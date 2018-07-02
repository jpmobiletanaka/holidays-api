class FullMoonService
  class << self
    def in(year = Date.current.year, month = nil)
      moons = {}.tap do |phases|
        (Date.civil(year, 1, 1)..Date.civil(year, 12, 31)).each do |date|
          phases[date.month] ||= []
          phases[date.month] << date.day if Lunartic.on_date(date).phase == :full
        end
      end
      return moons if month.blank?
      moons[month.to_i]
    end
  end
end
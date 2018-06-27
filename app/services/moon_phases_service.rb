class MoonPhasesService
  MOON_DAY = 29.5.days

  def full_moon_day_in(year, month)
    full_moons_in_year(year)[month.to_i]
  end

  def full_moons_in_year(year = Date.current.year)
    @full_moons_in_year ||= {}
    @full_moons_in_year[year] ||= {}.tap do |phases|
      phase = easter_in_year(year) - MOON_DAY
      while (phase += MOON_DAY).year == year
        phases[phase.month] ||= []
        phases[phase.month] << phase.day
      end
      phase = easter_in_year(year)
      while (phase -= MOON_DAY).year == year
        phases[phase.month] ||= []
        phases[phase.month] << phase.day
      end
    end
  end

  private

  def easter_in_year(year)
    @easter_in_year       ||= {}
    @easter_in_year[year] ||= calculate_easter_in_year(year)
  end

  # strong math, too hard, do not even try to figure it out :D
  def calculate_easter_in_year(year)
    a = year % 19
    b = year / 100
    c = year % 100
    d = b / 4
    e = b % 4
    f = (b + 8) / 25
    g = (b - f + 1) / 3
    h = (19 * a + b - d - g + 15) % 30
    i = c / 4
    k = c % 4
    l = (32 + 2 * e + 2 * i - h - k) % 7
    m = (a + 11 * h + 22 * l) / 451
    x = h + l - 7 * m + 114
    month = x / 31
    day = (x % 31) + 1
    Date.new(year, month, day)
  end
end
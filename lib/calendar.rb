require 'json'
require 'time'
require_relative 'year'
require_relative 'date_utils'

class Calendar
  MAX_HOLIDAYS = 100

  def initialize()
    @y = Time.now.year
    @m = Time.now.month
    @d = Time.now.day
    @year = Year.new(@y)
  end

  def holidays(count = 3)
    if count > MAX_HOLIDAYS
      raise "Cannot request more than #{MAX_HOLIDAYS} holidays at once."
    end

    holidays = Array.new

    while holidays.length < count
      month_index = @m.to_s

      if defined? @year.get_holidays[month_index] and @year.get_holidays[month_index].is_a? Array
        @year.get_holidays[month_index].each do |holiday|
          if holidays.length < count and holiday['day'].to_i >= @d
            holidays.push(holiday)
          end
        end
      end

      if holidays.length < count
        self.next_month()
      end
    end

    holidays
  end

  def holidays_json(count = 3)
    self.holidays(count).to_json
  end

  def holidays_print(count = 3)
    holidays = self.holidays(count)

    holidays.each do |holiday|
      t = DateUtils.create_date(holiday['year'], holiday['month'], holiday['day'])
      date = t.strftime('%a, %b %e, %Y')

      puts "#{date} #{holiday['description']}"
    end
  end

  def next_month()
    if @m == 12
      @m = 1
      @y += 1
      @d = 1
    else
      @m += 1
      @d = 1
    end

    @year = Year.new(@y)
  end
end

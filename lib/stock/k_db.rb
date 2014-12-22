class KDb
  
  attr_accessor :code_times, :stocks

  def read_codes(date)
    open("http://k-db.com/stocks/#{format(date)}?download=csv", 'r') do |r|
      r.readlines[2..-1].map do |line|
        line.sub(/-.*/, '').chomp
      end
    end
  end

  def read_one_minute_stocks(code, date)
    @code_times = []
    @stocks     = []
    open("http://k-db.com/stocks/#{code}/minutely?date=#{format(date)}&download=csv", "r") do |r|
      r.readlines[2..-1].each do |line|
        data = line.split(',')
        time = CodeTime.new
        time.code = code
        time.date = date
        time.time = data[1].sub(':', '')
        stock = Stock.new
        stock.open     = data[2]
        stock.high     = data[3]
        stock.low      = data[4]
        stock.close    = data[5]
        stock.volume   = data[6]
        stock.adjusted = 0
        next if stock.volume.to_i == 0 
        @code_times << time
        @stocks     << stock
      end
    end
  end

  def format(date)
    if date.length == 8
      date = "#{date.year}-#{date.month}-#{date.day}"
    end
  end
end

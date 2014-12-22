class KDb
  
  attr_accessor :splits, :stocks

  def read_codes(date)
    open("http://k-db.com/stocks/#{format(date)}?download=csv", 'r') do |r|
      r.readlines[2..-1].map do |line|
        line.sub(/-.*/, '').chomp
      end
    end
  end

  def read_stocks(code, from ,to)
    @stocks  = []
    @splits = []
    date = from
    while date <= to
      begin
        open("http://k-db.com/stocks/#{code}/minutely?date=#{format(date)}&download=csv", "r") do |r|
          r.readlines[2..-1].each do |line|
            data  = line.split(',')
            key   = CodeTime.new(code, date, data[1].sub(':', ''))
            stock = Stock.new
            stock.key      = key
            stock.open     = data[2]
            stock.high     = data[3]
            stock.low      = data[4]
            stock.close    = data[5]
            stock.volume   = data[6]
            stock.adjusted = 0
            next if stock.volume.to_i == 0 
            @stocks << stock
          end
        end
      rescue => ex
        p ex.backtrace
        puts ex.message
        puts "http://k-db.com/stocks/#{code}/minutely?date=#{format(date)}&download=csv can't open"
      ensure
        date = (Date.parse(date) + 1).strftime("%Y%m%d")
      end
    end 
    true
  end

  def format(date)
    if date.length == 8
      date = "#{date.year}-#{date.month}-#{date.day}"
    end
  end
end

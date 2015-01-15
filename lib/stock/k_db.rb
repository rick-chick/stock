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
    data = nil
    while date <= to
      begin
        open("http://k-db.com/stocks/#{code}/minutely?date=#{format(date)}&download=csv", "r") do |r|
          content = r.readlines[2..-1]
          raise RejectedError if content.nil?
          content.each do |line|
            data  = line.split(',')
            raise RejectedError if data.length == 1
            raise DateMissingError if date != data[0].gsub('-','')
            key   = CodeTime.new(code, 
                                 date, 
                                 data[1].sub(':', ''))
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
      rescue DateMissingError
      rescue RejectedError
        #puts "rejected #{proxy.current}. retry with other proxy "
        read_stocks(code, from, to)
      rescue Net::ReadTimeout, 
        Errno::ETIMEDOUT, 
        OpenURI::HTTPError,
        Errno::ECONNREFUSED,
        Errno::ECONNRESET => ex
        #puts "read time error. proxy: #{proxy.current}"
        #proxy.delete
        read_stocks(code, from, to)
      rescue => ex
        p data
        p ex.backtrace
        puts ex.message
        puts ex.class.name
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

  class RejectedError < StandardError
    def initialize
      super("rejected")
    end
  end

  class DateMissingError < StandardError
    def initialize
      super('date is too old or holiday')
    end
  end

end

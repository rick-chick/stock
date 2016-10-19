class NetStockCsv
  
  attr_accessor :splits, :stocks, :path

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
    data = nil
    begin
      open(@path, "r") do |r|
        content = r.readlines[2..-1]
        raise RejectedError if content.nil?
        content.each do |line|
          data  = line.split(',')
          raise RejectedError if data.length == 1
          key   = CodeTime.new(code, 
                               data[0].gsub('-',''), 
                               data[1].gsub(':', '')[0..3])
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
      puts data
      puts ex.backtrace
      puts ex.message
      puts ex.class.name
    ensure
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

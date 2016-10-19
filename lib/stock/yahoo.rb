class Yahoo

  attr_accessor :stocks, :splits

  def read_stocks(code, from ,to)
    begin
      @stocks = []
      @splits = []
      @url = nil
      begin
        @url  ||= "http://info.finance.yahoo.co.jp/history/?code=#{code}&sy=#{from.year}&sm=#{from.month}&sd=#{from.day}&ey=#{to.year}&em=#{to.month}&ed=#{to.day}&tm=d"
        @doc    = Nokogiri::HTML(open(@url))
        @doc.css("table.boardFin").each do |table|
          tds = table.css("td")
          while tds.length > 0
            date       = tds.shift.content.split(/[^\d]/)
            year       = "%04d" % date[0]
            month      = "%02d" % date[1]
            day        = "%02d" % date[2]
            element    = tds.shift
            if element.attribute("class") and element.attribute("class").value == "through" 
              array = element.content.split(/[^\d\.]/).select {|v| not v.empty?}
              split = Split.new
              split.code   = code
              split.date   = year + month + day
              split.before = array[0]
              split.after  = array[1]
              @splits << split
            else
              s = Stock.new
              s.key      = CodeDate.new(code, year + month + day)
              s.open     = element.content.gsub(",", "")
              s.high     = tds.shift.content.gsub(",", "")
              s.low      = tds.shift.content.gsub(",", "")
              s.close    = tds.shift.content.gsub(",", "")
              if not Fx::CODES.include? code
                s.volume   = tds.shift.content.gsub(",", "")
                s.adjusted = tds.shift.content.gsub(",", "")
              else
                s.volume   = nil
                s.adjusted = nil
              end
              @stocks << s
            end
          end
        end
      end while has_next?
      true
    rescue => ex
      puts ex.backtrace
      puts ex.message
      false
    end
  end

  def has_next?
    begin
      ul = @doc.css("ul.ymuiPagingBottom")[0]
      a  = ul.css("a").last
      if not a or a.content =~ /\d/
        false
      else
        @url = a.attribute("href")
        true
      end
    rescue  => ex
      puts ex.message
      puts ex.backtrace
      false
    end
  end
end


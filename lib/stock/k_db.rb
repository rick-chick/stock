class KDb

  def read_codes(date)
    open("http://k-db.com/stocks/#{format(date)}?download=csv", 'r') do |r|
      r.readlines[2..-1].map do |line|
        line.sub(/-.*/, '').chomp
      end
    end
  end

  def format(date)
    if date.length == 8
      date = "#{date.year}-#{date.month}-#{date.day}"
    end
  end
end

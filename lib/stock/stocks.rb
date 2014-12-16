class Stocks < Array

  def self.merge(*stocks)
    results  = Stocks.new
    targets  = stocks.clone
    currents = targets.map { |target| target.shift }
    while (compact = currents.compact).length > 0
      min   = compact.min
      items = []
      nexts = []
      currents.each_with_index do |t, i|
        if t and min.subkey == t.subkey
          items << t
          nexts << targets[i].shift
        else
          items << nil
          nexts << t
        end
      end
      currents = nexts
      results << s = Stock.new
      s.value   = yield items
      s.subkey  = min.subkey
    end
    Stocks[*results]
  end

  def calc(length)
    ret = (self.length-length+1).times.map do |i|
      value = yield self[i..(i+length-1)]
      Stock.new(self[i+length-1].key , *value)
    end
    Stocks[*ret]
  end

  def each_code 
    current = self.first
    ret = self.slice_before { |stock|
      prev, current = current, stock
      prev.code != current.code 
    }.map do |stocks|
      s = yield Stocks[*stocks]
      Stocks[*s]
    end
  end

  def log
    calc(2) do |stocks|
      Math.log(stocks[1].value / stocks[0].value)
    end
  end

  def bol(length)
    calc(length) do |stocks|
      ave = calc_ave(stocks)
      dev = Math.sqrt(calc_dev(stocks, ave))
      [(stocks[-1].value - ave) / dev, {ave: ave, upper: ave + dev, bottom: ave - dev}]
    end
  end

  def change(length)
    calc(length+1) do |stocks|
      stocks[0].value ?
        stocks[-1].value / stocks[0].value :
        Float::NAN
    end
  end

  def sum(length)
    calc(length) do |stocks|
      stocks.inject(0) {|r, stock| r += stock.value}
    end
  end

  def stc(length)
    calc(length) do |stocks|
      max = calc_max(stocks)
      min = calc_min(stocks)
      (stocks[-1].value - min) / (max - min) * 100
    end
  end

  def calc_ave(stocks)
    ave = 0
    stocks.each do |stock|
      ave += stock.value 
    end 
    ave /= stocks.length
  end

  def calc_dev(stocks, ave)
    stddev = 0
    stocks.each do |stock|
      stddev += (stock.value - ave) ** 2
    end 
    stddev /= stocks.length
  end

end

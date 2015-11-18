class Stocks < Array

  def self.merge(*stocks)
    results  = Stocks.new
    targets  = Marshal.load(Marshal.dump(stocks))
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
      results << s = min.clone
      s.value = yield items
    end
    Stocks[*results]
  end

  def self.merge!(*stocks)
    results  = Stocks.new
    currents = stocks.map { |target| target.shift }
    while (compact = currents.compact).length > 0
      min   = compact.min
      items = []
      nexts = []
      currents.each_with_index do |t, i|
        if t and min.subkey == t.subkey
          items << t
          nexts << stocks[i].shift
        else
          items << nil
          nexts << t
        end
      end
      currents = nexts
      results << s = min.clone
      s.value = yield items
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

  def values
    map do |stock|
      stock.value
    end
  end

  def fill_blank(length=10)
    type   = first.class
    code   = first.code
    blanks = Date.range(first.date, last.date).map do |date|
      type.blank_instances(code, date)
    end.flatten
    Stocks.merge(self, blanks) do |x, y| 
      x ? x.value : nil
    end.calc(length) do |stocks|
      value = nil
      stocks.reverse_each do |s|
        next if not s.value
        value = s.value; break
      end
      value
    end
  end

  def grid(size, min, max)
    dx = (max - min) / size
    calc(1) do |stocks|
      (stocks[0].value / dx).to_i * dx
    end
  end

  def log(length=1)
    calc(length+1) do |stocks|
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

  def remez(w = [])
    if w.length == 0 
      w = [-7.520197083715248e-04 ,-2.957742096785156e-03 ,-1.982041947077555e-03 ,-1.264674259642701e-03 ,1.425221392641072e-03 ,4.987685064782665e-03 ,8.301389580363647e-03 ,9.480976808582451e-03 ,6.846075729568570e-03 ,-3.076334082755999e-04 ,-1.094235627233285e-02 ,-2.201772131222604e-02 ,-2.895758474252658e-02 ,-2.681497837153691e-02 ,-1.188463145963680e-02 ,1.676580699203125e-02 ,5.641679093693356e-02 ,1.008608624892523e-01 ,1.416957352921660e-01 ,1.704312154240885e-01 ,1.807817792895172e-01 ,1.704312154240885e-01 ,1.416957352921660e-01 ,1.008608624892523e-01 ,5.641679093693356e-02 ,1.676580699203125e-02 ,-1.188463145963680e-02 ,-2.681497837153691e-02 ,-2.895758474252658e-02 ,-2.201772131222604e-02 ,-1.094235627233285e-02 ,-3.076334082755999e-04 ,6.846075729568570e-03 ,9.480976808582451e-03 ,8.301389580363647e-03 ,4.987685064782665e-03 ,1.425221392641072e-03 ,-1.264674259642701e-03 ,-1.982041947077555e-03 ,-2.957742096785156e-03 ,-7.520197083715248e-04 ]
    end
    calc(w.length) do |stocks|
      ret = 0
      stocks.each_with_index {|s, i| ret += s.value * w[i]}
      ret
    end
  end

  def dev(length, &block) 
    if not block
      calc(length) do |stocks|
        Math.sqrt(calc_dev(stocks, calc_ave(stocks)))
      end
    else
      calc(length) do |stocks|
        Math.sqrt(calc_dev(stocks, block.call(stocks)))
      end
    end
  end

  def diff(length=1)
    calc(length+1) do |stocks|
      stocks.last.value - stocks.first.value
    end
  end

  def delay(length)
    return self if length == 0
    calc(length+1) do |stocks|
      stocks.first.value
    end
  end

  def calc_ave(stocks)
    ave = 0
    stocks.each do |stock|
      ave += stock.value 
    end 
    ave /= stocks.length
  end

  def ave(length)
    calc(length) do |stocks|
      calc_ave(stocks)
    end
  end

  def calc_dev(stocks, ave)
    stddev = 0
    stocks.each do |stock|
      stddev += (stock.value - ave) ** 2
    end 
    stddev /= stocks.length
  end

  def diff_rate(length = 1)
    calc(length+1) do |stocks|
      (stocks.last.value - stocks.first.value) / stocks.first.value.abs
    end
  end
end

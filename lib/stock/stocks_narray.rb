#             day1  day2  day3 ...
# open        1     2     2
# high        2     1     3
# low         1     1     1
# close       3     3     1
# volume      10    50    20
# adjusted    3     3     1
# value       0.5   0.1   0.3
#
class Stocks < NArray

  def opens
    [true, 0].refer
  end

  def highs
    [true, 1].refer
  end

  def highs
    [true, 2].refer
  end

  def lows
    [true, 3].refer
  end

  def closes
    [true, 4].refer
  end

  def volumes
    [true, 5].refer
  end

  def adjusteds
    [true, 6].refer
  end

  def values
    [true, 7].refer
  end

  def self.merge(*stocks)

  end

  def self.merge!(*stocks)

  end

  def calc(length)

  end
end

require File.expand_path(File.dirname(__FILE__)) + '/require.rb'

to   = Date.latest
from = to.prev(50)
cls  = Stock.closes from ,to
chng = cls.each_code {|stocks| stocks.change(1)}
cl   = chng.length
s = Stocks.merge(*chng) do |stocks|
	stocks.inject(0) do |sum, stock| 
		(stock ? sum += stock.value : sum) / cl
	end
end

p s

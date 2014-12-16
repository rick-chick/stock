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
				if t and min.key == t.key
					items << t
					nexts << targets[i].shift
				else
					items << nil
					nexts << t
				end
			end
			currents = nexts
			value    = yield items
			results << Stock.new(min.key, value)
		end
		results
	end

	def calc(length)
		ret = (self.length-length+1).times.map do |i|
			value = yield self[i..(i+length-1)]
			Stock.new(self[i+length-1].key , value)
		end
		Stocks[*ret]
	end

end

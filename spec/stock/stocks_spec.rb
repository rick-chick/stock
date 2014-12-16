require File.expand_path(File.dirname(__FILE__)) + '/../spec_helper.rb'

describe "Stocks" do

	describe "merge" do
		let(:stock1) { [Stock.new("20140202", 1), 
									  Stock.new("20140203", 3)]}
		let(:stock2) { [Stock.new("20140202", 2), 
										Stock.new("20140203", 4)] }
		let(:stock3) { [Stock.new("20140203", 2)] }
		let(:stock4) { [Stock.new("20140202", 2)] }

		context "2 arrays which have complete matched keys" do
			let(:result) do
				Stocks.merge(stock1, stock2) do |s1, s2|
					a = s1 ? s1.value : 0
					b = s2 ? s2.value : 0
					a + b
				end
			end
			specify { expect(result.length).to be 2 }
			specify { expect(result[0].value).to be 3 }
			specify { expect(result[1].value).to be 7 }
		end

		context "2 arrays which first key are not matched" do
			let(:result) do
				Stocks.merge(stock1, stock3) do |s1, s2|
					a = s1 ? s1.value : 0
					b = s2 ? s2.value : 0
					a + b
				end
			end
			specify { expect(result.length).to be 2 }
			specify { expect(result[0].value).to be 1 }
			specify { expect(result[1].value).to be 5 }
		end

		context "2 arrays which last key are not matched" do
			let(:result) do
				Stocks.merge(stock1, stock4) do |s1, s2|
					a = s1 ? s1.value : 0
					b = s2 ? s2.value : 0
					a + b
				end
			end
			specify { expect(result.length).to be 2 }
			specify { expect(result[0].value).to be 3 }
			specify { expect(result[1].value).to be 3 }
		end

		context "3 arrays" do
			let(:result) do
				Stocks.merge(stock1, stock3, stock4) do |s1, s2, s3|
					a = s1 ? s1.value : 0
					b = s2 ? s2.value : 0
					c = s3 ? s3.value : 0
					a + b + c
				end
			end
			specify { expect(result.length).to be 2 }
			specify { expect(result[0].value).to be 3 }
			specify { expect(result[1].value).to be 5 }
		end
	end

	describe "calc" do
		let(:stocks) { Stocks[*[Stock.new("20140202", 1), 
									          Stock.new("20140203", 3),
		                        Stock.new("20140204", 4),
		                       ] 
		                     ]
		             }

		specify do 
			ret = stocks.calc(2) do |s|
				s.inject(0) {|r, stock| r += stock.value }
			end
			expect(ret.length).to eq 2
			expect(ret[0].key).to eq "20140203"
			expect(ret[0].value).to eq 4
			expect(ret[1].key).to eq "20140204"
			expect(ret[1].value).to eq 7
		end
	end

	describe "each_code" do
		let(:code1) { "1301" }
		let(:code2) { "1302" }
		let(:date1) { "20140101" }
		let(:date2) { "20140102" }
		let(:date3) { "20140103" }
		let(:stocks) { 
			ss = Stocks.new
			s = Stock.new
			s.code  = code1
			s.date  = date1
			s.value = 1
			ss << s
			s = Stock.new
			s.code  = code1
			s.date  = date2
			s.value = 1
			ss << s
			s = Stock.new
			s.code  = code1
			s.date  = date3
			s.value = 1
			ss << s
			s = Stock.new
			s.code  = code2
			s.date  = date1
			s.value = 1
			ss << s
			s = Stock.new
			s.code  = code2
			s.date  = date3
			s.value = 1
			ss << s
		}
		specify do
			ret = []
			stocks.each_code do |stocks|
				ret << stocks
			end
			expect(ret.length).to eq 2
			expect(ret[0].length).to eq 3
			ret[0].each {|stock| expect(stock.code).to eq code1}
			expect(ret[1].length).to eq 2
			ret[1].each {|stock| expect(stock.code).to eq code2}
		end
	end
end

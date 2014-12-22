require File.expand_path(File.dirname(__FILE__)) + '/../spec_helper.rb'

describe "Stocks" do

	describe "merge" do
    let(:code_date1) { CodeDate.new("1301", "20140202") }
    let(:code_date2) { CodeDate.new("1301", "20140203") }
    let(:code_date3) { CodeDate.new("1301", "20140204") }
		let(:stock1) { [Stock.new(code_date1, 1), 
									  Stock.new(code_date2, 3)]}
		let(:stock2) { [Stock.new(code_date1, 2), 
										Stock.new(code_date2, 4)] }
		let(:stock3) { [Stock.new(code_date2, 2)] }
		let(:stock4) { [Stock.new(code_date1, 2)] }

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
    let(:code_date1) { CodeDate.new("1301", "20140202") }
    let(:code_date2) { CodeDate.new("1301", "20140203") }
    let(:code_date3) { CodeDate.new("1301", "20140204") }
		let(:stocks) { Stocks[*[Stock.new(code_date1, 1), 
									          Stock.new(code_date2, 3),
		                        Stock.new(code_date3, 4),
		                       ] 
		                     ]
		             }

		specify do 
			ret = stocks.calc(2) do |s|
				s.inject(0) {|r, stock| r += stock.value }
			end
			expect(ret.length).to eq 2
			expect(ret[0].key).to eq code_date2
			expect(ret[0].value).to eq 4
			expect(ret[1].key).to eq code_date3
			expect(ret[1].value).to eq 7
		end
	end

	describe "each_code" do
    let(:code_date1) { CodeDate.new("1301", "20140101") }
    let(:code_date2) { CodeDate.new("1301", "20140102") }
    let(:code_date3) { CodeDate.new("1301", "20140103") }
    let(:code_date4) { CodeDate.new("1302", "20140101") }
    let(:code_date5) { CodeDate.new("1302", "20140103") }
		let(:stocks) { 
			ss = Stocks.new
			ss << Stock.new(code_date1, 1)
			ss << Stock.new(code_date2, 1)
      ss << Stock.new(code_date3, 1)
      ss << Stock.new(code_date4, 1)
      ss << Stock.new(code_date5, 1)
		}
		specify do
			ret = []
			stocks.each_code do |stocks|
				ret << stocks
			end
			expect(ret.length).to eq 2
			expect(ret[0].length).to eq 3
      ret[0].each {|stock| expect(stock.code).to eq code_date1.code}
			expect(ret[1].length).to eq 2
      ret[1].each {|stock| expect(stock.code).to eq code_date4.code}
		end
	end
end

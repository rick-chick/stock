require File.expand_path(File.dirname(__FILE__)) + '/require.rb'

class Command

  def initialize 
    @yahoo = Yahoo.new
    @k_db  = KDb.new
  end

  def update(options = {})
    args = {"from" => nil, 
            "to"   =>nil,
            "code" =>nil,
    }.merge(options)
    args["from"] ||= Date.latest_after_a_day
    args["to"]   ||= Date.now
		if args["code"] 
			@yahoo.read_stocks(args["code"], args["from"] ,args["to"])
			stc_cnt  = @yahoo.stocks.inject(0) {|s, stock| s += stock.insert }
			spt_cnt  = @yahoo.splits.inject(0) {|s, split| s += split.insert }
		else
			@k_db.read_codes(args["to"]).each do |code|
				@yahoo.read_stocks(code, args["from"] ,args["to"])
				stc_cnt  = @yahoo.stocks.inject(0) {|s, stock| s += stock.insert }
				spt_cnt  = @yahoo.splits.inject(0) {|s, split| s += split.insert }
				puts "insert #{code}: #{stc_cnt}/#{stocks.length}"
				puts "insert #{code}: #{spt_cnt}/#{splits.length}"
			end
		end
  end

end

command = Command.new
case ARGV.shift
when "update"
  command.update(ARGV.getopts("", "from:", "to:", "code:"))
else
end

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
            "codefrom" =>nil,
            "init" => false,
    }.merge(options)
    args["from"] ||= Date.latest_after_a_day
    args["to"]   ||= Date.now
    codes = args["code"] ? 
      [args["code"]] : @k_db.read_codes(args["to"])
    codes.each do |code|
      next if args["codefrom"] and args["codefrom"] > code 
      while not @yahoo.read_stocks(code, args["from"] ,args["to"])
        sleep 60
      end
      stc_cnt  = @yahoo.stocks.inject(0) {|s, stock| s += stock.insert}
      spt_cnt  = @yahoo.splits.inject(0) {|s, split| s += split.insert }
      puts "insert stocks #{code}: #{stc_cnt}/#{@yahoo.stocks.length}"
      puts "insert splits #{code}: #{spt_cnt}/#{@yahoo.splits.length}"
      if not args["init"] and spt_cnt > 0 
        @yahoo.read_stocks(code, Date.oldest_of(code), args["to"])
        stc_cnt  = @yahoo.stocks.inject(0) {|s, stock| s += stock.update }
        puts "update stocks #{code}: #{stc_cnt}/#{@yahoo.stocks.length}"
      end
    end
  end

end

command = Command.new
case ARGV.shift
when "update"
  command.update(ARGV.getopts("", "from:", "to:", "code:", "codefrom:", "init"))
else
end

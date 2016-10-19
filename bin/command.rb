#!/bin/ruby
require File.dirname(File.expand_path(__FILE__)) + '/../lib/stock.rb'

class Command

  def initialize 
    @yahoo = Yahoo.new
    @k_db  = KDb.new
    @net_stock_csv  = NetStockCsv.new
  end

  def update(options = {})
    args = {"from" => nil, 
            "to"   =>nil,
            "code" =>nil,
            "codefrom" =>nil,
            "init" => false,
            "minute" => false,
            "path" => nil,
            "stop" => false,
    }.merge(options)
    p args
    args["from"] ||= Date.latest_after_a_day
    args["to"]   ||= Date.now
    if args["minute"] and args["blankskip"]
      codes = Code.have_some_trade_at(Date.latest)
    end
    codes  = args["code"] ? 
      [args["code"]] : @k_db.read_codes(args["to"])
    reader = args["minute"] ? @k_db: @yahoo
    if args["path"] then
      reader =  @net_stock_csv 
      reader.path = args["path"]
    end
    codes.each do |code|
      next if args["codefrom"] and args["codefrom"] > code 
      while not reader.read_stocks(code, args["from"] ,args["to"])
        sleep 60
      end
      stc_cnt  = 0 
      reader.stocks.each do |stock| 
        stc_cnt += stock.insert 
        if args["stop"]
          gets
        end
      end
      spt_cnt  = reader.splits.inject(0) {|s, split| s += split.insert }
      puts "insert stocks #{code}: #{stc_cnt}/#{reader.stocks.length}"
      puts "insert splits #{code}: #{spt_cnt}/#{reader.splits.length}"
      if not args["init"] and spt_cnt > 0 and not args["minute"]
        reader.read_stocks(code, Date.oldest_of(code), args["to"])
        stc_cnt  = reader.stocks.inject(0) {|s, stock| s += stock.update }
        puts "update stocks #{code}: #{stc_cnt}/#{reader.stocks.length}"
      end
      sleep 1 if args["minute"] and not args["path"]
    end
  end

end

command = Command.new
case ARGV.shift
when "update"
  command.update(ARGV.getopts("",
                             "from:",
                             "to:",
                             "code:",
                             "codefrom:",
                             "init",
                             "minute",
                             "blankskip",
                             "path:",
                             "stop"))
else
end

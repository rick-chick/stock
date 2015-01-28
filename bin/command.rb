#!/bin/ruby
require File.expand_path(File.dirname(__FILE__)) + '/stock.rb'

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
            "minute" => false,
    }.merge(options)
    args["from"] ||= Date.latest_after_a_day
    args["to"]   ||= Date.now
    if args["minute"] and args["blankskip"]
      codes = Code.have_some_trade_at(Date.latest)
    end
    codes  = args["code"] ? 
      [args["code"]] : @k_db.read_codes(args["to"])
    reader = args["minute"] ? @k_db: @yahoo
    codes.each do |code|
      next if args["codefrom"] and args["codefrom"] > code 
      while not reader.read_stocks(code, args["from"] ,args["to"])
        sleep 60
      end
      stc_cnt  = reader.stocks.inject(0) {|s, stock| s += stock.insert }
      spt_cnt  = reader.splits.inject(0) {|s, split| s += split.insert }
      puts "insert stocks #{code}: #{stc_cnt}/#{reader.stocks.length}"
      puts "insert splits #{code}: #{spt_cnt}/#{reader.splits.length}"
      if not args["init"] and spt_cnt > 0 and not args["minute"]
        reader.read_stocks(code, Date.oldest_of(code), args["to"])
        stc_cnt  = reader.stocks.inject(0) {|s, stock| s += stock.update }
        puts "update stocks #{code}: #{stc_cnt}/#{reader.stocks.length}"
      end
      sleep 5 if args["minute"]
    end
  end

end

command = Command.new
case ARGV.shift
when "update"
  command.update(ARGV.getopts("", "from:", "to:", "code:", "codefrom:", "init", "minute", "blankskip"))
else
end

dir = File.dirname(File.expand_path(__FILE__))
dir = File.dirname(File.expand_path(__FILE__))
require "#{dir}/../lib/require"

while true
  sleep 1
  time = Time.now.strftime('%H%M')
  break if time >= '0900'
end

amount = 38495

to = Date.latest
codes  = Code.tradable_codes(to, 250)
codes  = codes.map do |code|
  c = Daily.closes(to.prev(100) ,to , code: code)
  w81    = [3.510283128004727e-03 ,-3.182775042430418e-03 ,-2.608271819534801e-03 ,-2.383537183636792e-03 ,-2.249093866490492e-03 ,-2.026671638472229e-03 ,-1.614714398638625e-03 ,-9.558834001876536e-04 ,-4.340900948198147e-05 ,1.086903587924003e-03 ,2.353362614492617e-03 ,3.642427198101253e-03 ,4.810998585141105e-03 ,5.705148113434410e-03 ,6.168080588057612e-03 ,6.064577014514579e-03 ,5.292700504543464e-03 ,3.807743274800248e-03 ,1.628714176996889e-03 ,-1.146639691453862e-03 ,-4.346630387086137e-03 ,-7.723198934437562e-03 ,-1.097041271025898e-02 ,-1.373608331016219e-02 ,-1.565378007151405e-02 ,-1.636511530559449e-02 ,-1.555811975615863e-02 ,-1.298982245558401e-02 ,-8.519790268302819e-03 ,-2.122814377753883e-03 ,6.090383947401229e-03 ,1.587772698950535e-02 ,2.686487094919399e-02 ,3.857364800034739e-02 ,5.044203190013506e-02 ,6.187133687448786e-02 ,7.225222309157596e-02 ,8.101859598278773e-02 ,8.765986074026005e-02 ,9.180345541796421e-02 ,9.322272930445610e-02 ,9.180345541796421e-02 ,8.765986074026005e-02 ,8.101859598278773e-02 ,7.225222309157596e-02 ,6.187133687448786e-02 ,5.044203190013506e-02 ,3.857364800034739e-02 ,2.686487094919399e-02 ,1.587772698950535e-02 ,6.090383947401229e-03 ,-2.122814377753883e-03 ,-8.519790268302819e-03 ,-1.298982245558401e-02 ,-1.555811975615863e-02 ,-1.636511530559449e-02 ,-1.565378007151405e-02 ,-1.373608331016219e-02 ,-1.097041271025898e-02 ,-7.723198934437562e-03 ,-4.346630387086137e-03 ,-1.146639691453862e-03 ,1.628714176996889e-03 ,3.807743274800248e-03 ,5.292700504543464e-03 ,6.064577014514579e-03 ,6.168080588057612e-03 ,5.705148113434410e-03 ,4.810998585141105e-03 ,3.642427198101253e-03 ,2.353362614492617e-03 ,1.086903587924003e-03 ,-4.340900948198147e-05 ,-9.558834001876536e-04 ,-1.614714398638625e-03 ,-2.026671638472229e-03 ,-2.249093866490492e-03 ,-2.383537183636792e-03 ,-2.608271819534801e-03 ,-3.182775042430418e-03 ,3.510283128004727e-03 ]
  remez8 = c.remez(w81)
  dev    = c.dev(81) {|s| s.remez(w81).last.value}
  next if not (remez8[-1] and c[-1].value > remez8[-1].value + dev[-1].value)
  next if Code.unit(code) * c.last.value > amount
  code
end.compact
codes.sort!

class Log

  class << self
    
    def initialize
      File.open('log.txt' , 'w') do |file|
        file << ''
      end
    end
  end

  def self.puts(line)
    STDOUT << line + "\n"
    File.open('log.txt', 'a') do |file|
      file << line + "\n"
    end
  end
end

class Decide

  PENDING = 0
  BUY     = 1
  SELL    = 2

  attr_accessor :stocks

  def initialize
    @last_signals = {}
  end

  def increment(code, price)
    date  = Time.now.strftime('%Y%m%d')
    time  = Time.now.strftime('%H%M')
    if @stocks[code].last.key.time == time or 
      @stocks[code].last.value == price
      @stocks[code].pop
    end
    s       = Minute.new
    s.key   = CodeTime.new code, date, time
    s.value = price
    @stocks[code] << s
  end

  def buy?(code)
    closes = @stocks[code]
    w21    = [1.454334937016120e-03 ,3.535951962782457e-03 ,-7.682036764357356e-03 ,-1.109007547933841e-02 ,1.611981582627617e-02 ,3.203567074202579e-02 ,-2.641722611049958e-02 ,-8.339349834774878e-02 ,3.487311588791309e-02 ,3.100094633183384e-01 ,4.618406428525572e-01 ,3.100094633183384e-01 ,3.487311588791309e-02 ,-8.339349834774878e-02 ,-2.641722611049958e-02 ,3.203567074202579e-02 ,1.611981582627617e-02 ,-1.109007547933841e-02 ,-7.682036764357356e-03 ,3.535951962782457e-03 ,1.454334937016120e-03]
    w81    = [3.510283128004727e-03 ,-3.182775042430418e-03 ,-2.608271819534801e-03 ,-2.383537183636792e-03 ,-2.249093866490492e-03 ,-2.026671638472229e-03 ,-1.614714398638625e-03 ,-9.558834001876536e-04 ,-4.340900948198147e-05 ,1.086903587924003e-03 ,2.353362614492617e-03 ,3.642427198101253e-03 ,4.810998585141105e-03 ,5.705148113434410e-03 ,6.168080588057612e-03 ,6.064577014514579e-03 ,5.292700504543464e-03 ,3.807743274800248e-03 ,1.628714176996889e-03 ,-1.146639691453862e-03 ,-4.346630387086137e-03 ,-7.723198934437562e-03 ,-1.097041271025898e-02 ,-1.373608331016219e-02 ,-1.565378007151405e-02 ,-1.636511530559449e-02 ,-1.555811975615863e-02 ,-1.298982245558401e-02 ,-8.519790268302819e-03 ,-2.122814377753883e-03 ,6.090383947401229e-03 ,1.587772698950535e-02 ,2.686487094919399e-02 ,3.857364800034739e-02 ,5.044203190013506e-02 ,6.187133687448786e-02 ,7.225222309157596e-02 ,8.101859598278773e-02 ,8.765986074026005e-02 ,9.180345541796421e-02 ,9.322272930445610e-02 ,9.180345541796421e-02 ,8.765986074026005e-02 ,8.101859598278773e-02 ,7.225222309157596e-02 ,6.187133687448786e-02 ,5.044203190013506e-02 ,3.857364800034739e-02 ,2.686487094919399e-02 ,1.587772698950535e-02 ,6.090383947401229e-03 ,-2.122814377753883e-03 ,-8.519790268302819e-03 ,-1.298982245558401e-02 ,-1.555811975615863e-02 ,-1.636511530559449e-02 ,-1.565378007151405e-02 ,-1.373608331016219e-02 ,-1.097041271025898e-02 ,-7.723198934437562e-03 ,-4.346630387086137e-03 ,-1.146639691453862e-03 ,1.628714176996889e-03 ,3.807743274800248e-03 ,5.292700504543464e-03 ,6.064577014514579e-03 ,6.168080588057612e-03 ,5.705148113434410e-03 ,4.810998585141105e-03 ,3.642427198101253e-03 ,2.353362614492617e-03 ,1.086903587924003e-03 ,-4.340900948198147e-05 ,-9.558834001876536e-04 ,-1.614714398638625e-03 ,-2.026671638472229e-03 ,-2.249093866490492e-03 ,-2.383537183636792e-03 ,-2.608271819534801e-03 ,-3.182775042430418e-03 ,3.510283128004727e-03 ]
    remez8 = closes.remez(w81)
    dev    = closes.dev(81) {|stocks| stocks.remez(w81).last.value}
    a = Stocks.merge(closes , remez8, dev) do |c,d,e|
      next if not e
      c.value > (d.value + e.value)
    end

    if @last_signals.key? code
      prev, @last_signals[code] = @last_signals[code], a.last.value
      if not prev and a.last.value
        Log.puts "#{code} #{@stocks[code].last.key.time} #{@stocks[code].last.value} #{prev} #{a.last.value} buy"
        BUY
      elsif prev and not a.last.value
        Log.puts "#{code} #{@stocks[code].last.key.time} #{@stocks[code].last.value} #{prev} #{a.last.value} sell"
        SELL
      else
        Log.puts "#{code} #{@stocks[code].last.key.time} #{@stocks[code].last.value} #{prev} #{a.last.value} pending"
        PENDING
      end
    else
      Log.puts "#{code} #{@stocks[code].last.key.time} nil #{a.last.value} pending"
      @last_signals[code] = a.last.value
      PENDING
    end
  end
end

class Player

  attr_accessor :hands

  def initialize
    @buy_order  = {}
    @sell_order = {}
    @amount     = 500000
  end

  def check_contract(hands)
    @hands = hands
    contract_to_buy do |code|
      @hands.include? code
    end
    contract_to_sell do |code|
      not @hands.include? code
    end
  end

  def contract_to_buy
    @buy_order.each do |code,value|
      next if value == 0
      next if not yield(code)
      @amount -= value
      @buy_order[code] = 0 
      Log.puts "#{code} contracted to buy and, #{@amount}"
    end
  end

  def contract_to_sell
    @sell_order.each do |code,value|
      next if value == 0
      next if not yield(code)
      @amount += value
      @sell_order[code] = 0 
      Log.puts "#{code} contracted to sell and, #{@amount}"
    end
  end

  def wish_to_buy?(code, price)
    return false if @amount < price 
    return false if self.have_order_to_buy? code
    return false if self.have code
    Log.puts "i want to buy #{code} at #{price}"
    return true
  end

  def wish_to_sell?(code, price)
    return false if not self.have code
    return false if self.have_order_to_sell? code
    Log.puts "i want to sell #{code} at #{price}"
    return true
  end

  def order_to_buy?(code, price)
    return if not wish_to_buy?(code, price)
    @buy_order[code] = price
    Log.puts "i order to buy #{code} at #{price}"
  end

  def order_to_sell?(code, price)
    return if not wish_to_sell?(code, price)
    @sell_order[code] = price
    Log.puts "i order to sell #{code} at #{price}"
  end

  def have_order_to_buy?(code)
    @buy_order.keys.include? code
  end

  def have_order_to_sell?(code)
    @sell_order.keys.include? code
  end

  def have(code)
    @hands.include? code
    Log.puts @hands.to_s
  end

end

player   = Player.new
agent    = MatsuiStock.new
signal   = Decide.new
agent.a  = ARGV[2]

agent.log_in(ARGV[0], ARGV[1])
codes    = (agent.open_hands.keys + codes).uniq
p codes

signal.stocks = codes.inject({}) do |hash,code|
  hash.update code => Minute.closes(to.prev(1), to, code: code)
end

while true
  codes.each do |code|
    begin
      status = agent.watch(code)
      cost   = status[:price] * status[:unit]
      player.check_contract(agent.open_hands)
      signal.increment(code, status[:price])
      case signal.buy?(code)
      when Decide::BUY
        if player.order_to_buy?(code, cost)
          agent.buy(code, status[:price], status[:unit])
        end
      when Decide::SELL
        if player.order_to_sell?(code, cost)
          agent.sell(code, status[:price], player.hands[code][:volume])
        end
      when Decide::PENDING
        #
      end
    rescue => ex
      Log.puts ex.message.to_s
      Log.puts ex.backtrace.to_s
    ensure
      break if Time.now.strftime('%H%M') == '1500'
    end
  end
end

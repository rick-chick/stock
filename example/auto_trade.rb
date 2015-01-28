dir = File.dirname(File.expand_path(__FILE__))
require "#{dir}/../lib/require"

to = Date.latest
codes  = Code.tradable_codes(to, 250)
codes.map! do |code|
  stocks = Minute.closes(to, to, code: code)
  dev    = stocks.dev(60)
  next if not dev.last
  dev    = dev.last.value / stocks.last.value
  next if dev < 0.01
  code
end

codes.compact!
codes.sort!
puts codes

def buy?(closes)
  remez4 = closes.remez
  w21    = [1.454334937016120e-03 ,3.535951962782457e-03 ,-7.682036764357356e-03 ,-1.109007547933841e-02 ,1.611981582627617e-02 ,3.203567074202579e-02 ,-2.641722611049958e-02 ,-8.339349834774878e-02 ,3.487311588791309e-02 ,3.100094633183384e-01 ,4.618406428525572e-01 ,3.100094633183384e-01 ,3.487311588791309e-02 ,-8.339349834774878e-02 ,-2.641722611049958e-02 ,3.203567074202579e-02 ,1.611981582627617e-02 ,-1.109007547933841e-02 ,-7.682036764357356e-03 ,3.535951962782457e-03 ,1.454334937016120e-03]
  w81    = [3.510283128004727e-03 ,-3.182775042430418e-03 ,-2.608271819534801e-03 ,-2.383537183636792e-03 ,-2.249093866490492e-03 ,-2.026671638472229e-03 ,-1.614714398638625e-03 ,-9.558834001876536e-04 ,-4.340900948198147e-05 ,1.086903587924003e-03 ,2.353362614492617e-03 ,3.642427198101253e-03 ,4.810998585141105e-03 ,5.705148113434410e-03 ,6.168080588057612e-03 ,6.064577014514579e-03 ,5.292700504543464e-03 ,3.807743274800248e-03 ,1.628714176996889e-03 ,-1.146639691453862e-03 ,-4.346630387086137e-03 ,-7.723198934437562e-03 ,-1.097041271025898e-02 ,-1.373608331016219e-02 ,-1.565378007151405e-02 ,-1.636511530559449e-02 ,-1.555811975615863e-02 ,-1.298982245558401e-02 ,-8.519790268302819e-03 ,-2.122814377753883e-03 ,6.090383947401229e-03 ,1.587772698950535e-02 ,2.686487094919399e-02 ,3.857364800034739e-02 ,5.044203190013506e-02 ,6.187133687448786e-02 ,7.225222309157596e-02 ,8.101859598278773e-02 ,8.765986074026005e-02 ,9.180345541796421e-02 ,9.322272930445610e-02 ,9.180345541796421e-02 ,8.765986074026005e-02 ,8.101859598278773e-02 ,7.225222309157596e-02 ,6.187133687448786e-02 ,5.044203190013506e-02 ,3.857364800034739e-02 ,2.686487094919399e-02 ,1.587772698950535e-02 ,6.090383947401229e-03 ,-2.122814377753883e-03 ,-8.519790268302819e-03 ,-1.298982245558401e-02 ,-1.555811975615863e-02 ,-1.636511530559449e-02 ,-1.565378007151405e-02 ,-1.373608331016219e-02 ,-1.097041271025898e-02 ,-7.723198934437562e-03 ,-4.346630387086137e-03 ,-1.146639691453862e-03 ,1.628714176996889e-03 ,3.807743274800248e-03 ,5.292700504543464e-03 ,6.064577014514579e-03 ,6.168080588057612e-03 ,5.705148113434410e-03 ,4.810998585141105e-03 ,3.642427198101253e-03 ,2.353362614492617e-03 ,1.086903587924003e-03 ,-4.340900948198147e-05 ,-9.558834001876536e-04 ,-1.614714398638625e-03 ,-2.026671638472229e-03 ,-2.249093866490492e-03 ,-2.383537183636792e-03 ,-2.608271819534801e-03 ,-3.182775042430418e-03 ,3.510283128004727e-03 ]
  remez2 = closes.remez(w21)
  remez8 = closes.remez(w81)
  a = Stocks.merge(closes , remez2, remez4, remez8) do |c,d,e,f|
    next if not f
    c.value > d.value and 
    d.value > e.value and
    e.value > f.value
  end
  a.last.value
end

set = {}
codes.each do |code|
  set[code] = Minute.closes(to.prev(1), to, code: code)
end

agent = MatsuiStock.new
agent.log_in(ARGV[0], ARGV[1])
File.open('log.txt', 'w') do |file|
  while true
    begin
      codes.each do |code|
        agent.watch(code) do |status|
          date = Time.now.strftime('%Y%m%d')
          time = Time.now.strftime('%H%M')
          pric = status[:price]
          next if time <= '0900'
          if set[code].last.time = time
            set[code].pop
          end
          set[code] << s = Minute.new
          s.key = CodeTime.new code, date, time
          s.value = pric
          if buy?(set[code])
            line =  "#{code} #{date} #{time} #{pric} buy"
            puts line
            file << line + "\n"
          else
            line =  "#{code} #{date} #{time} #{pric} sell"
            puts line
            file << line + "\n"
          end
          agent.exit
        end
        sleep 1
      end
      break if Time.now.strftime('%H%M') == '1500'
    rescue => ex
      file << ex.message
      file << ex.stacktrace
      sleep 1
    ensure
    end
  end
end

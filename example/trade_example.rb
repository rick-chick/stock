require File.expand_path(File.dirname(__FILE__), '../lib/stock')

codes = ["1570", "1568", "1357"]
exit if HolidayJapan.check(Date.today)
board = MatsuiStock::StockBoard.new
board.log_in(ARGV[0], ARGV[1])
board.pin_code = ARGV[2]
board.open
board.set(codes)
prev = nil
point = nil
t = Time.now
break_start_time = Time.new(t.year, t.month, t.day, 11, 30, 0)
break_end_time = Time.new(t.year, t.month, t.day, 12, 30, 0)
trade_exit_time = Time.new(t.year, t.month, t.day, 15, 0, 0)
trade_start_time = Time.new(t.year, t.month, t.day, 9, 0, 0)
lm = {}
board.watch do |boards|
	begin
		if not (break_start_time <= Time.now and Time.now <= break_end_time)
			#board1 = boards.find {|a| a.code == codes[0]}
			#board2 = boards.find {|a| a.code == codes[1]}
			#if board1 and board2
			#	board1.upsert
			#	board2.upsert
			#	buy   = board1.buy - board2.sell + 20
			#	sell  = board1.sell - board2.buy - 20
			#	value = board1.price - board2.price
			#	point = buy if buy == sell
			#	disps = [value, buy, sell]
			#	if not prev == disps
			#		pair = Pair.new
			#		pair.key = PairTime.new(codes[0], codes[1], Time.now)
			#		pair.close = value
			#		pair.high = buy
			#		pair.low = sell
			#		pair.open = point
			#		pair.insert
			#	end
			#	prev = disps
			#end
			boards[0..-1].each do |board|
				board.upsert
				m = Minute.new 
				m.key = CodeTime.new board.code
				m.close = board.price
				m.high = board.buy
				m.low = board.sell
        if lm[board.code] != m.to_s 
          m.insert
          lm[board.code] = m.to_s
        end
			end
		end
	rescue => ex
		p ex.backtrace
  ensure
    boards = nil
	end
  Time.now <= trade_exit_time
end


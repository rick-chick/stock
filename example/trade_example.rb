require File.expand_path(File.dirname(__FILE__), '../lib/stock')

exit if HolidayJapan.check(Date.today)
codes = ["1568", "1579"]
board = MatsuiStock::StockBoard.new
board.log_in(ARGV[0], ARGV[1])
board.pin_code = ARGV[2]
board.open
board.set(codes)
prev = nil
point = nil
player = Player.new
player.ticks = [10, 10]
player.volumes = [10, 10]
player.codes = codes
agent = SmbcStock.new
agent.log_in ARGV[2], ARGV[3], ARGV[4]
player.hands = agent.hands
player.orders = agent.orders
invalid_orders = []
t = Time.now
break_start_time = Time.new(t.year, t.month, t.day, 11, 30, 0)
break_end_time = Time.new(t.year, t.month, t.day, 12, 30, 0)
board.watch do |boards|
  if not (break_start_time <= Time.now and Time.now <= break_end_time)
    board1 = boards.find {|a| a.code == codes[0]}
    board2 = boards.find {|a| a.code == codes[1]}
    if board1 and board2
      buy   = board1.buy - board2.sell + 20
      sell  = board1.sell - board2.buy - 20
      value = board1.price - board2.price
      point = buy if buy == sell
      disps = [value, buy, sell]
      if not prev == disps
        pair = Pair.new
        pair.key = PairTime.new(codes[0], codes[1], Time.now)
        pair.close = value
        pair.high = buy
        pair.low = sell
        pair.open = point
        pair.insert
      end
      prev = disps

      player.boards = boards
      if player.have_uncontracted_order?
        player.hands = agent.hands
        player.orders = agent.orders
      else
        invalid_orders = []
      end

      tmp = []
      invalid_orders.each do |order|
        result = agent.recept(order)
        if result.orderd?
          result.insert
        else
          tmp << order
        end
      end
      invalid_orders = tmp
      invalid_orders.sort! {|a, b| a <=> b}

      player.decide do |order|
        result = agent.recept(order)
        if result.orderd?
          result.insert
        else
          invalid_orders << order
        end
      end
    end
  end

  if invalid_orders.length > 0
    p 'invalid_orders'
    p invalid_orders
  end

  if agent.unloaded_over_interval?
    p 'reload'
    agent.reload
  end
  true
end

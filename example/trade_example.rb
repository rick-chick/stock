require File.expand_path(File.dirname(__FILE__), '../lib/stock')

codes = [1568, 1579]
board = MatsuiStock::StockBoard.new
board.log_in(ARGV[0], ARGV[1])
board.pin_code = ARGV[2]
board.open
board.set(codes)
prev = nil
point = nil
player = Player.new
player.tick = 10
player.volume = 10
player.codes = codes
agent = SmbcStock.new
agent.log_in ARGV[2], ARGV[3], ARGV[4]
player.hands = agent.hands
player.orders = agent.orders
board.watch do |boards|
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
    end
    player.decide do |order|
      agent.recept order
    end
  end
  if agent.unloaded_over_interval?
    agent.reload
  end
  true
end

require File.expand_path(File.dirname(__FILE__), '../lib/stock')

board = MatsuiStock::StockBoard.new
board.log_in(ARGV[0], ARGV[1])
board.pin_code = ARGV[2]
board.open
board.set([1568, 1579])
prev = nil
point = nil
board.watch do |boards|
  board2 = boards.find {|a| a.code == 1568}
  board1 = boards.find {|a| a.code == 1579}
  if board1 and board2
    buy   = board1.buy - board2.sell + 20
    sell  = board1.sell - board2.buy - 20
    value = board1.price - board2.price
    point = buy if buy == sell
    db = buy - point if point
    ds = sell - point if point
    disps = [value, buy, sell, db, ds]
    if not prev == disps
      pair = Pair.new
      pair.key = PairTime.new(1568, 1579, Time.now)
      pair.close = value
      pair.high = buy
      pair.low = sell
      pair.open = point
      pair.insert
      p pair
    end
    prev = disps
  end
  true
end

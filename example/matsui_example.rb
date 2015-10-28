#coding: utf-8
require File.expand_path(File.dirname(__FILE__), '../lib/stock/board')
require File.expand_path(File.dirname(__FILE__), '../lib/stock/matsui')
require 'nokogiri'

agent = MatsuiStock.new
agent.log_in(ARGV[0], ARGV[1])
agent.pin_code = ARGV[2]
agent.open_board
agent.set_board([1568, 1579])
prev = nil
agent.watch_board do |boards|
  board1 = boards.find {|a| a.code == 1568}
  board2 = boards.find {|a| a.code == 1579}
  buy   = board1.buy - board2.sell + 20
  sell  = board1.sell - board2.buy - 20
  value = board1.price - board2.price
  disps = [value, buy, sell]
  mark = 'd' if buy == sell
  mark = 'u' if (buy - sell).abs > 20
  puts [board1.time, disps, mark].flatten.join(' ') if not prev == disps
  prev = disps
  true
end

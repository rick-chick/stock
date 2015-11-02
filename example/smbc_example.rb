LIB_DIR = File.expand_path(File.dirname(__FILE__), "../lib")
require 'open-uri'
require 'nokogiri'
require 'selenium-webdriver'
require LIB_DIR + '/stock/order'
require LIB_DIR + '/stock/status'
require LIB_DIR + '/stock/player'
require LIB_DIR + '/stock/board'
require LIB_DIR + '/stock/hand'
require LIB_DIR + '/stock/smbc'

agent = SmbcStock.new
agent.log_in(ARGV[0].strip, ARGV[1].strip, ARGV[2].strip)
hash = {code: 1579,
        volume: 20,
        price: 12000}
order =  Order::Buy.new hash
agent.recept order
p order.status
if order.orderd?
  order = agent.orders.find {|o| o.orderd? }
  order.volume = 10
  agent.recept order
  p order.status
  order = agent.orders.find {|o| o.orderd? }
  order.price = 12600
  agent.recept order
  p order.status
  #order = agent.orders.find {|o| o.orderd? }
  #order.force = true
  #agent.recept order
  #p order.status
  order = agent.orders.find {|o| o.orderd? }
  order = agent.cancel order
  p order.status
end

hash = {code: 1579,
        volume: 20,
        price: 17100}
order = Order::Sell.new hash
agent.recept order
p order.status
if order.orderd?
  order = agent.orders.find {|o| o.orderd? }
  order.volume = 10
  agent.recept order
  p order.status
  order = agent.orders.find {|o| o.orderd? }
  order.price = 17200
  agent.recept order
  p order.status
  #order = agent.orders.find {|o| o.orderd? }
  #order.force = true
  #agent.recept order
  #p order.status
  order = agent.orders.find {|o| o.orderd? }
  order = agent.cancel order
  p order.status
end

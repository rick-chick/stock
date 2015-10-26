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
hands = agent.hands
hands.each do |hand|
  order = hand.to_o
  order.force = true
  order = agent.recept order
  p order
end

require File.expand_path('../lib/stock/', File.dirname(__FILE__))
require File.expand_path('controller', File.dirname(__FILE__))

codes = ["1570"]
agent = SmbcStock.new
agent.log_in ARGV[2], ARGV[3], ARGV[4]
player = Player::Normal.new
player.ticks = [10]
player.volumes = [300]
player.codes = codes
player.safe_trade = false
player.ll = 800
player.sl = 100
player.lt = 3.5
player.st = 1.8

controller = Controller.new
controller.run(codes, agent, player)

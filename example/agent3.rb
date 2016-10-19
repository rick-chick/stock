require File.expand_path('../lib/stock', File.dirname(__FILE__))
require File.expand_path('controller', File.dirname(__FILE__))

codes = ["1357"]
agent = SmbcStock.new
agent.log_in ARGV[2], ARGV[3], ARGV[4]
player = Player::Normal.new
player.ticks = [1]
player.volumes = [900]
player.codes = codes
player.safe_trade = false
player.ll = 900
player.sl = 100
player.lt = 3.1 
player.st = 1.6

controller = Controller.new
controller.run(codes, agent, player)

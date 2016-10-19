class Controller

  attr_accessor :codes, :agent, :player

  def run(codes, agent, player)
    invalid_orders = []
    puts codes[0]
    player.hands = agent.hands.find_all {|h| h.code == codes[0]}
    player.orders = agent.orders.find_all {|h| h.code == codes[0]}
    player.set_prev_status
    while true
      board1 = Board.select codes[0]
      if board1.length == 1 
        player.boards = [board1[0]]
        if player.have_uncontracted_order?
          loop do
            player.hands = agent.hands.find_all {|h| h.code == codes[0]}
            player.orders = agent.orders.find_all {|h| h.code == codes[0]}
            break if agent.hands.find_all {|h| h.code == codes[0]}.length == player.hands.length and 
              agent.orders.find_all {|h| h.code == codes[0]}.length == player.orders.length
          end 
        end

        player.invalid_orders = invalid_orders
        invalid_orders = []
        count = 0
        player.decide do |order|
          successed = []
          have_order = order.each do |o|
            result = agent.recept(o)
            if not result.denied?
              result.insert 
              successed << o
            end
          end
          if not have_order and order.repeat?
            invalid_orders << order
          elsif have_order
            count += 1
          end
        end
        if count > 0
          loop do
            player.hands = agent.hands.find_all {|h| h.code == codes[0]}
            player.orders = agent.orders.find_all {|h| h.code == codes[0]}
            break if agent.hands.find_all {|h| h.code == codes[0]}.length == player.hands.length and 
              agent.orders.find_all {|h| h.code == codes[0]}.length == player.orders.length
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
      break if Time.now.strftime('%H%M') == '1501'
    end
  end
end

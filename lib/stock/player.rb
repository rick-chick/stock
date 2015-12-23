#encoding: utf-8
class Player

  attr_accessor :boards, :hands, :orders, :ticks, :volumes

  def codes=(codes)
    @codes = []
    codes.each {|code| @codes << code.to_s}
  end

  def decide(&agent)
    orders = []
    case assemble_status
    when AssembleStatus::BE_CONTRACTED
      @codes.each_with_index do |code, i|
        @orders.find_all {|o| o.orderd? and o.code == code}.map do |order|
          order.date = Time.now
          order.edited = true
          order.force = true
          orders << order
        end
      end
    when AssembleStatus::PROCESSING
    when AssembleStatus::COMPLETE
      case order_status
      when OrderStatus::TAKE_PROFIT
        case hold_status
        when HoldStatus::NONE
        when HoldStatus::BUY
          orders = repay
        when HoldStatus::SELL
          orders = repay
        end
      when OrderStatus::BUY
        case hold_status
        when HoldStatus::NONE
          orders = buy
        when HoldStatus::BUY
        when HoldStatus::SELL
          orders = [repay, buy]
        end
      when OrderStatus::SELL
        case hold_status
        when HoldStatus::NONE
          orders = sell
        when HoldStatus::BUY
          orders = [repay, sell]
        when HoldStatus::SELL
        end
      when OrderStatus::LOSS_CUT
        case hold_status
        when HoldStatus::NONE
        when HoldStatus::BUY
          orders = repay
        when HoldStatus::SELL
          orders = repay
        end
      when OrderStatus::PENDING
        case hold_status
        when HoldStatus::NONE
        when HoldStatus::BUY
        when HoldStatus::SELL
        end
      end
    end
    if orders.flatten.length > 0
      @loss_cut = false
      AssembleStatus.current = AssembleStatus::PROCESSING
    end
    orders.flatten.each {|order| agent.call order }
  end

  def buy
    validate_board
    result = []
    board1 = @boards.find {|b| b.code == @codes[0] }
    result << Order::Buy.new(
      code: @codes[0],
      price: board1.buy + @ticks[0],
      volume: @volumes[0],
    )
    board2 = @boards.find {|b| b.code == @codes[1] }
    result << Order::Sell.new(
      code: @codes[1],
      price: board2.sell - @ticks[1],
      volume: @volumes[1],
    )
    result
  end

  def sell
    validate_board
    result = []
    board1 = @boards.find {|b| b.code == @codes[0] }
    result << Order::Sell.new(
      code: @codes[0],
      price: board1.sell - @ticks[0],
      volume: @volumes[0],
    )
    board2 = @boards.find {|b| b.code == @codes[1] }
    result << Order::Buy.new(
      code: @codes[1],
      price: board2.buy + @ticks[1],
      volume: @volumes[1],
    )
    result
  end

  def repay
    validate_board
    result = []
    @codes.each_with_index do |code, i|
      board = @boards.find {|b| b.code == code }
      @hands.find_all {|h| h.code == code}.each do |hand|
        order = hand.to_o
        case hand.trade_kbn
        when :buy
          order.price = board.sell - @ticks[i]
        when :sell
          order.price = board.buy + @ticks[i]
        end
        result << order
      end
    end
    result
  end

  def validate_board
    raise InvalidBoadError if not @boards or @boards.length == 0
    raise InvalidBoadError if not @boards.find {|b| b.code == @codes[0]}
    raise InvalidBoadError if not @boards.find {|b| b.code == @codes[1]}
  end

  def order_status
    board1 = @boards.find {|b| b.code == @codes[0]}
    board2 = @boards.find {|b| b.code == @codes[1]}
    last_orders = Order.last_orders
    last_order1 = last_orders.find {|o| o.code == @codes[0] and not o.repay?}
    last_order2 = last_orders.find {|o| o.code == @codes[1] and not o.repay?}
    if last_order1 and last_order2 and 
        (board1.buy - board2.sell + @ticks[0]) == (board1.sell - board2.buy - @ticks[1])
      last_diff = last_order1.price - last_order2.price

      # take_profit
      case HoldStatus.current
      when HoldStatus::BUY
        current_diff = board1.sell - @ticks[0] - ( board2.buy + @ticks[1] )
        if current_diff - last_diff >= @ticks[0] * 3
          p "c " + current_diff.to_s
          p "l " + last_diff.to_s
          return OrderStatus.current = OrderStatus::TAKE_PROFIT
        end
      when HoldStatus::SELL
        current_diff = board1.buy + @ticks[0] - ( board2.sell - @ticks[1] )
        if last_diff - current_diff >= @ticks[0] * 3
          p "c " + current_diff.to_s
          p "l " + last_diff.to_s
          return OrderStatus.current = OrderStatus::TAKE_PROFIT
        end
      end

      # loss_cut
      case HoldStatus.current
      when HoldStatus::BUY
        current_diff = board1.sell - @ticks[0] - ( board2.buy + @ticks[1] )
        @loss_cut = true if (current_diff - last_diff <= - @ticks[0] * 3)
      when HoldStatus::SELL
        current_diff = board1.buy + @ticks[0] - ( board2.sell - @ticks[1] )
        @loss_cut = true if (last_diff - current_diff <= - @ticks[0] * 3)
      end
      if @loss_cut and current_diff == last_diff
          return OrderStatus.current = OrderStatus::LOSS_CUT
      end
    end
    stocks = Pair.select_equilibrium_price(@codes[0], @codes[1], Time.now, 31)
    if stocks.length < 31
      return OrderStatus.current = OrderStatus::PENDING
    end
    bols = stocks.bol(30)
    if bols[-1].value < -2
      OrderStatus.current = OrderStatus::BUY
    elsif bols[-1].value > 2
      OrderStatus.current = OrderStatus::SELL
    else
      OrderStatus.current = OrderStatus::PENDING
    end
  end

  def hold_status
    if @hands.length == 0
      return HoldStatus.current = HoldStatus::NONE
    end
    if @hands.find {|h| h.trade_kbn == :buy and h.code == @codes[0]} and
        @hands.find {|h| h.trade_kbn == :sell and h.code == @codes[1]}
      sum1 = 0
      @hands.find_all {|h| h.trade_kbn == :buy and h.code == @codes[0]}.each do |h|
        sum1 += h.volume
      end
      sum2 = 0
      @hands.find_all {|h| h.trade_kbn == :sell and h.code == @codes[1]}.each do |h|
        sum2 += h.volume
      end
      if sum1 == sum2
        return HoldStatus.current = HoldStatus::BUY
      end
    end
    if @hands.find {|h| h.trade_kbn == :sell and h.code == @codes[0]} and
        @hands.find {|h| h.trade_kbn == :buy and h.code == @codes[1]}
      sum1 = 0
      @hands.find_all {|h| h.trade_kbn == :sell and h.code == @codes[0]}.each do |h|
        sum1 += h.volume
      end
      sum2 = 0
      @hands.find_all {|h| h.trade_kbn == :buy and h.code == @codes[1]}.each do |h|
        sum2 += h.volume
      end
      if sum1 == sum2
        return HoldStatus.current = HoldStatus::SELL
      end
    end
    HoldStatus.current = HoldStatus::INVALID
  end

  def assemble_status
    uncontracteds = @orders.find_all {|o| o.orderd? }
    if uncontracteds.length == 0
      return AssembleStatus.current = AssembleStatus::COMPLETE
    end
    board = @boards.group_by {|b| b.code}
    uncontracteds.each do |o|
      raise OrderUndefinedCodeError if not board.key? o.code
      idx = @codes.index o.code
      tick = @ticks[idx]
      if o.buy?
        if board[o.code][0].buy > o.price
          p o.code
          p "b " + board[o.code][0].buy.to_s
          p "o " + o.price.to_s
          return AssembleStatus.current = AssembleStatus::BE_CONTRACTED
        end
      elsif o.sell?
        if board[o.code][0].sell < o.price
          p o.code
          p "s " + board[o.code][0].sell.to_s
          p "o " + o.price.to_s
          return AssembleStatus.current = AssembleStatus::BE_CONTRACTED
        end
      end
    end
    AssembleStatus.current = AssembleStatus::PROCESSING
  end

  def have_uncontracted_order?
    not AssembleStatus.current == AssembleStatus::COMPLETE or HoldStatus.current == HoldStatus::INVALID
  end

  class OrderUndefinedCodeError < StandardError; end
  class InvalidBoadError < StandardError; end

end

class Status

  attr_accessor :type

  def self.current=(status)
    if @current != status
        p "#{@current}:#{@current ? @current.type : ""} => #{status}:#{status.type}"
      @current = status
    end
  end

  def self.current
    @current
  end
end

class OrderStatus < Status

  def initialize(type)
    @type = type
  end

  BUY = OrderStatus.new("buy")
  SELL = OrderStatus.new("sell")
  LOSS_CUT = OrderStatus.new("loss_cut")
  TAKE_PROFIT = OrderStatus.new("take_profit")
  PENDING = OrderStatus.new("pending")
end

class HoldStatus < Status

  def initialize(type)
    @type = type
  end

  NONE = HoldStatus.new("none")
  BUY = HoldStatus.new("buy")
  SELL = HoldStatus.new("sell")
  INVALID = HoldStatus.new("invalid")
end

class AssembleStatus < Status

  def initialize(type)
    @type = type
  end

  PROCESSING = AssembleStatus.new("processing")
  BE_CONTRACTED = AssembleStatus.new("be_contracted")
  COMPLETE = AssembleStatus.new("complete")
end

#encoding: utf-8
class Player

  attr_accessor :boards, :hands, :orders, :tick, :volume

  def codes=(codes)
    @codes = []
    codes.each {|code| @codes << code.to_s}
  end

  def decide(&agent)
    orders = []
    case assemble_status
    when AssembleStatus::BE_CONTRACTED
      orders = @orders.find_all {|o| o.orderd? }.map do |order|
        order.force = true
        order.edited = true
        order
      end
    when AssembleStatus::PROCESSING
    when AssembleStatus::COMPLETE
      case order_status
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
      price: board1.buy + @tick,
      volume: @volume,
    )
    board2 = @boards.find {|b| b.code == @codes[1] }
    result << Order::Sell.new(
      code: @codes[1],
      price: board2.sell - @tick,
      volume: @volume,
    )
    result
  end

  def sell
    validate_board
    result = []
    board1 = @boards.find {|b| b.code == @codes[0] }
    result << Order::Sell.new(
      code: @codes[0],
      price: board1.sell - @tick,
      volume: @volume,
    )
    board2 = @boards.find {|b| b.code == @codes[1] }
    result << Order::Buy.new(
      code: @codes[1],
      price: board2.buy + @tick,
      volume: @volume,
    )
    result
  end

  def repay
    validate_board
    result = []
    @codes.each do |code|
      board = @boards.find {|b| b.code == code }
      @hands.find_all {|h| h.code == code}.each do |hand|
        order = hand.to_o
        case hand.trade_kbn
        when :buy
          order.price = board.sell - @tick
        when :sell
          order.price = board.buy + @tick
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
    stocks = Pair.select_equilibrium_price(@codes[0], @codes[1], Time.now, 31)
    if stocks.length < 31
      return OrderStatus.current = OrderStatus::PENDING
    end
    bols = stocks.bol(30)
    if bols[-1].value < -1.5
      OrderStatus.current = OrderStatus::BUY
    elsif bols[-1].value > 1.5
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
      if o.buy?
        if board[o.code][0].buy > o.price
          return AssembleStatus.current = AssembleStatus::BE_CONTRACTED
        end
      elsif o.sell?
        if board[o.code][0].sell < o.price
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

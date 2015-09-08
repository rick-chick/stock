#encoding: utf-8
class Player

  attr_accessor :boards, :hands, :orders, :codes, :tick, :volume

  def decide(&agent)
    orders = []
    case hold_status
    when HoldStatus::ASSEMBLING
      case assemble_status 
      when AssembleStatus::BE_CONTRACTED
        oreders = @orders.find_all {|o| o.orderd? }.map do |order|
          order.force = true
          order
        end
      end
    else
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
    @codes.each do |code|
      board = @boards.find {|b| b.code == code }
      @hands.find_all {|h| h.code == code}.each do |hand|
        order = hand.to_o
        case hand.trade_kbn 
        when :buy
          order.price = board.sell_price - @tick
        when :sell
          order.price = board.buy_price + @tick
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

  def order_satus 
  end

  def hold_status
    if orders.find {|o| o.orderd? and @codes.include? o.code}
      return HoldStatus::ASSEMBLING
    end
    if hands.length == 0
      return HoldStatus::NONE
    end
    if hands.find {|h| h.trade_kbn == :buy and h.code == @codes[0]} and
        hands.find {|h| h.trade_kbn == :sell and h.code == @codes[1]}
      sum1 = 0
      hands.find_all {|h| h.trade_kbn = :buy and h.code == @codes[0]}.each do |h|
        sum1 += h.volume
      end
      sum2 = 0
      hands.find_all {|h| h.trade_kbn = :buy and h.code == @codes[0]}.each do |h|
        sum2 += h.volume
      end
      return HoldStatus::BUY
    end
    if hands.find {|h| h.trade_kbn == :sell and h.code == @codes[0]} and
        hands.find {|h| h.trade_kbn == :buy and h.code == @codes[1]}
      return HoldStatus::SELL
    end
  end

  def assemble_status
    board = @boards.group_by {|b| b.code}
    @orders.find_all {|o| o.orderd? }.each do |o|
      raise OrderUndefinedCodeError if not board.key? o.code
      if o.trade_kbn == :buy
        if board[o.code][0].price > o.price
          return AssembleStatus::BE_CONTRACTED
        end
      elsif o.trade_kbn == :sell
        if board[o.code][0].price < o.price
          return AssembleStatus::BE_CONTRACTED
        end
      end
    end
    AssembleStatus::PROCESSING
  end

  class OrderUndefinedCodeError < StandardError; end
  class InvalidBoadError < StandardError; end

end

class OrderStatus
  BUY = 0
  SELL = 1
  LOSS_CUT = 2
  PENDING = 3
end

class HoldStatus
  NONE = 0
  BUY = 1
  SELL = 2
  ASSEMBLING = 3
end

class AssembleStatus
  PROCESSING = 0
  BE_CONTRACTED = 1
end

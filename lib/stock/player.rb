#encoding: utf-8
class Player

  attr_accessor :boards, :hands, :orders, :ticks, :volumes, :f, :invalid_orders, :step

  def initialize
    @invalid_orders = []
  end

  def codes=(codes)
    @codes = []
    codes.each {|code| @codes << code.to_s}
  end

  def invalid_orders=(orders)
    @invalid_orders = orders
  end

  def decide(&agent)
    orders = []
    hold_status
    case assemble_status
    when AssembleStatus::INVALID
      orders = @invalid_orders
    when AssembleStatus::BE_CONTRACTED
      @codes.each_with_index do |code, i|
        b = @boards.find {|b| b.code == code }
        @orders.find_all {|o| o.orderd? and o.code == code}.map do |order|
          order.date = Time.now
          case order
          when Order::Buy::Repay
            order.edited = true
            order.price = order.price + @ticks[i]
            orders << order
          when Order::Sell::Repay
            order.edited = true
            order.price = order.price - @ticks[i]
            orders << order
          when Order::Buy
            order.cancel = true
            order.next = buy[0]
            order.next.price = order.price + @ticks[i]
            prev = order.next
            buy[1..-1].each do |o|
              prev.next = o
              prev = o
            end
            orders << order
          when Order::Sell
            order.cancel = true
            order.next = sell[0]
            order.next.price = order.price - @ticks[i]
            prev = order.next
            sell[1..-1].each do |o|
              prev.next = o
              prev = o
            end
            orders << order
          end
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
        orders.flatten!
        orders.each {|o| o.opperation = 't'}
      when OrderStatus::BUY
        case hold_status
        when HoldStatus::NONE
          orders = buy
        when HoldStatus::BUY
        when HoldStatus::SELL
          orders = [repay, buy]
        when HoldStatus::INVALID
          orders = buy
          orders.each do |order|
            hand = @hands.find {|h| h.code == order.code and h.buy?}
            order.volume -= hand.volume if hand
          end
          if @hands.find {|h| h.sell?}
            orders.unshift repay
          end
        end
      when OrderStatus::SELL
        case hold_status
        when HoldStatus::NONE
          orders = sell
        when HoldStatus::BUY
          orders = [repay, sell]
        when HoldStatus::SELL
        when HoldStatus::INVALID
          orders = buy
          orders.each do |order|
            hand = @hands.find {|h| h.code == order.code and h.buy?}
            order.volume -= hand.volume if hand
          end
          if @hands.find {|h| h.sell?}
            orders.unshift repay
          end
        end
      when OrderStatus::LOSS_CUT
        case hold_status
        when HoldStatus::NONE
        when HoldStatus::BUY
          orders = [repay, sell].flatten
          @codes.each_with_index do |code, i|
            orders.find_all {|o| o.code == code }.each do |o|
              o.price -= 5 * @ticks[i]
            end
          end
        when HoldStatus::SELL
          orders = [repay, buy].flatten
          @codes.each_with_index do |code, i|
            orders.find_all {|o| o.code == code }.each do |o|
              o.price += 5 * @ticks[i]
            end
          end
        end
        orders.flatten!
        orders.each {|o| o.opperation = 'l'}
      when OrderStatus::PENDING
        case hold_status
        when HoldStatus::NONE
        when HoldStatus::BUY
        when HoldStatus::SELL
        end
      end
    end
    ret = orders.flatten
    puts ret if ret.length > 0
    ret.each {|order| agent.call order }
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
    result.uniq {|o| o.edit_url}.find_all {|o| o.edit_url}
  end

  def validate_board
    raise InvalidBoadError if not @boards or @boards.length == 0
    raise InvalidBoadError if not @boards.find {|b| b.code == @codes[0]}
    raise InvalidBoadError if not @boards.find {|b| b.code == @codes[1]}
  end

  def valid_status?
    assemble_status
    hold_status
    @codes.each do |code|
      if HoldStatus.current == HoldStatus::NONE or
        HoldStatus.current == HoldStatus::INVALID
        if AssembleStatus.current == AssembleStatus::COMPLETE
          return false
        end
      elsif HoldStatus.current == HoldStatus::SELL or
        HoldStatus.current == HoldStatus::BUY
        if AssembleStatus.current == AssembleStatus::PROCESSING or
        AssembleStatus.current == AssembleStatus::BE_CONTRACTED or 
        AssembleStatus.current == AssembleStatus::INVALID
          return false
        end
      end
    end
    return true
  end

  def set_prev_status
    hold_status
    if HoldStatus.current.buy?
      OrderStatus.current = OrderStatus::BUY
    elsif HoldStatus.current.sell?
      OrderStatus.current = OrderStatus::SELL
    end
  end

  def order_status
    board = @boards.group_by {|b| b.code}
    #if board[@codes[0]][0].buy_volume < @volumes[0] or
    #	 board[@codes[0]][0].sell_volume < @volumes[0] or
    #	 board[@codes[1]][0].buy_volume < @volumes[1] or
    #	 board[@codes[1]][0].sell_volume < @volumes[1]
    #  return OrderStatus.current = OrderStatus::PENDING
    #end
    all = Pair.select_equilibrium_price(@codes[0], @codes[1], Time.now, 500)
    if all.length < 500
      return OrderStatus.current = OrderStatus::PENDING
    end
    bols = all[-120..-1].bol(100)
    mx = 0
    vmx= 0 
    [100, 150, 200, 250, 300, 350, 400].each do |length|
      stocks = all[-length..-1]
      x, y = [], []
      stocks.each_with_index do |s, i|
        x << i
        y << s.value
      end
      x = Daru::Vector[*x]
      y = Daru::Vector[*y]
      r = Statsample::Regression::Simple.new_from_vectors(x,y)
      if r.r2 > vmx 
        mx  = length
        vmx = r.r2
      end
    end

    s = all[-mx..-1]
    x, y = [], []
    s.each_with_index do |s, i|
      x << i
      y << s.value
    end
    x = Daru::Vector[*x]
    y = Daru::Vector[*y]
    r = Statsample::Regression::Simple.new_from_vectors(x,y)
    b = (y[mx-1] - r.y(mx-1)) / r.standard_error
    if r.a > all[-1].value
      if b < 0 and bols[-1].value > 0
        OrderStatus.current = OrderStatus::SELL
      else
        OrderStatus.current = OrderStatus::BUY
      end
    elsif r.a < all[-1].value
      if b > 0 and bols[-1].value < 0
        OrderStatus.current = OrderStatus::BUY
      else
        OrderStatus.current = OrderStatus::SELL
      end
    else
      OrderStatus.current = OrderStatus::PENDING
    end
  end

  def hold_status
    if @hands.find_all {|h| h.code == @codes[0] or h.code == @codes[1]}.length == 0
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
    uncontracteds = @orders.find_all {|o| o.orderd? and (o.code == @codes[0] or o.code == @codes[1])}
    if uncontracteds.length == 0
      return AssembleStatus.current = AssembleStatus::COMPLETE
    end
    board = @boards.group_by {|b| b.code}
    uncontracteds.each do |o|
      raise OrderUndefinedCodeError if not board.key? o.code
      idx = @codes.index o.code
      tick = @ticks[idx]
      if o.buy? and board[o.code][0].buy > o.price
        return AssembleStatus.current = AssembleStatus::BE_CONTRACTED
      elsif o.sell? and board[o.code][0].sell < o.price
        return AssembleStatus.current = AssembleStatus::BE_CONTRACTED
      end
    end
    AssembleStatus.current = AssembleStatus::PROCESSING
  end

  def have_uncontracted_order?
    not assemble_status == AssembleStatus::COMPLETE #or hold_status == HoldStatus::INVALID
  end

  class OrderUndefinedCodeError < StandardError; end
  class InvalidBoadError < StandardError; end

end

class Status

  attr_accessor :type

  def self.current=(status)
    if @current != status
      p "#{Time.now} #{@current}:#{@current ? @current.type : ""} => #{status}:#{status.type}"
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

  def self.current=(status)
    super(status)
    return if not (status == BUY or status == SELL)
    @prev = status
  end

  def self.prev
    @prev ||= PENDING
  end

  def self.prev=(status)
    @prev = status
  end

  def buy?
    @type == "buy"
  end

  def sell?
    @type == "sell"
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

  def buy?
    @type == "buy"
  end

  def sell?
    @type == "sell"
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
  INVALID = AssembleStatus.new("invalid")
end

class Normal < Player

  attr_accessor :safe_trade, :ll, :sl, :lt, :st

  def initialize
    super
    @thr = 0.1
    @safe_trade = true
  end

  def buy
    validate_board
    result = []
    board1 = @boards.find {|b| b.code == @codes[0] }
    result << Order::Buy.new(
      code: @codes[0],
      price: @safe_trade ? board1.buy + @ticks[0] : board1.buy ,
      volume: @volumes[0],
    )
    result
  end

  def sell
    validate_board
    result = []
    board1 = @boards.find {|b| b.code == @codes[0] }
    result << Order::Sell.new(
      code: @codes[0],
      price: @safe_trade ? board1.sell - @ticks[0] : board1.sell ,
      volume: @volumes[0],
    )
    result
  end

  def repay
    validate_board
    result = []
    board = @boards.find {|b| b.code == @codes[0] }
    @hands.find_all {|h| h.code == @codes[0]}.each do |hand|
      order = hand.to_o
      case hand.trade_kbn
      when :buy
        @safe_trade ? 
          order.price = board.sell - @ticks[0] :
          order.price = board.sell
      when :sell
        @safe_trade ? 
          order.price = board.buy + @ticks[0] :
          order.price = board.buy
      end
      result << order
    end
    result
  end

  def validate_board
    raise InvalidBoadError if not @boards or @boards.length == 0
    raise InvalidBoadError if not @boards.find {|b| b.code == @codes[0]}
  end

  def order_status
    board = @boards.group_by {|b| b.code}
    if board[@codes[0]][0].toku
      return OrderStatus.current = OrderStatus::PENDING
    end
    all = Minute.closes(nil, nil, code: @codes[0], count: (@ll+1))
    if all.length < @ll+1
      return OrderStatus.current = OrderStatus::PENDING
    end
    l_bol = all[-@ll..-1].bol(@ll)[-1].value
    s_bol = all[-@sl..-1].bol(@sl)[-1].value
    if @trend_follow.nil?
      bol = all[-@ll-1..-2].bol(@ll)[-1].value
      @trend_follow = (bol < -@lt or bol > @lt)
    end
    if @trend_follow
      if (OrderStatus.prev.buy? and l_bol < @lt) or
        (OrderStatus.prev.sell? and l_bol > -@lt)
        @trend_follow = false
      end
    elsif l_bol > @lt 
      @trend_follow = true 
      return OrderStatus.current = OrderStatus::BUY
    elsif l_bol < -@lt
      @trend_follow = true 
      return OrderStatus.current = OrderStatus::SELL
    end
    if @trend_follow
      #none
    elsif s_bol < -@st 
      return OrderStatus.current = OrderStatus::BUY
    elsif s_bol > @st 
      return OrderStatus.current = OrderStatus::SELL
    end
    OrderStatus.current = OrderStatus::PENDING
  end

  def hold_status
    if @hands.find_all {|h| h.code == @codes[0]}.length == 0
      return HoldStatus.current = HoldStatus::NONE
    end
    if @hands.find {|h| h.buy? and h.code == @codes[0]}
      sum1 = 0
      @hands.find_all {|h| h.buy? and h.code == @codes[0]}.each do |h|
        sum1 += h.volume
      end
      if sum1 >= @volumes[0]
        return HoldStatus.current = HoldStatus::BUY
      end
    end
    if @hands.find {|h| h.sell? and h.code == @codes[0]}
      sum1 = 0
      @hands.find_all {|h| h.sell? and h.code == @codes[0]}.each do |h|
        sum1 += h.volume
      end
      if sum1 >= @volumes[0]
        return HoldStatus.current = HoldStatus::SELL
      end
    end
    HoldStatus.current = HoldStatus::INVALID
  end

  def assemble_status
    uncontracteds = @orders.find_all {|o| o.orderd? and 
                                      o.code.to_s == @codes[0].to_s}
    if uncontracteds.length == 0 and @invalid_orders.length == 0
      return AssembleStatus.current = AssembleStatus::COMPLETE
    end
    uncontracteds.each do |o|
      tick = @ticks[0]
      if o.buy? and @boards[0].buy > o.price
        return AssembleStatus.current = AssembleStatus::BE_CONTRACTED
      elsif o.sell? and @boards[0].sell < o.price
        return AssembleStatus.current = AssembleStatus::BE_CONTRACTED
      end
    end
    if @invalid_orders.length > 0 then
      AssembleStatus.current = AssembleStatus::INVALID
    else
      AssembleStatus.current = AssembleStatus::PROCESSING
    end
  end

  def average_buy
    v = 0
    s = 0
    @hands.find_all{|h| h.code == @codes[0] and h.buy?}.each do |h|
      s += h.order_price * h.volume
      v += h.volume
    end
    v > 0 ? s / v : 0
  end

  def average_sell
    v = 0
    s = 0
    @hands.find_all{|h| h.code == @codes[0] and h.sell?}.each do |h|
      s += h.order_price * h.volume
      v += h.volume
    end
    v > 0 ? s / v : 0
  end

  def last_buy_order
    @orders.find_all{|o| o.code == @codes[0] and o.buy?}.sort{|a,b| b.no <=> a.no}[0]
  end

  def last_sell_order
    @orders.find_all{|o| o.code == @codes[0] and o.sell?}.sort{|a,b| b.no <=> a.no}[0]
  end

  def invalid_orders=(orders)
    super(orders)
  end

end


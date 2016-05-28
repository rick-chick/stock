#encoding: utf-8
class Player

  attr_accessor :boards, :hands, :orders, :ticks, :volumes, :f

  def codes=(codes)
    @codes = []
    codes.each {|code| @codes << code.to_s}
  end

  def decide(&agent)
    orders = []
    hold_status
    case assemble_status
    when AssembleStatus::BE_CONTRACTED
      @codes.each_with_index do |code, i|
        b = @boards.find {|b| b.code == code }
        @orders.find_all {|o| o.orderd? and o.code == code}.map do |order|
          order.date = Time.now
          order.edited = true
          case order
          when Order::Buy, Order::Buy::Repay
            order.price = order.price + @ticks[i]
          when Order::Sell, Order::Sell::Repay
            order.price = order.price - @ticks[i]
          end
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
        orders.flatten!
        orders.each {|o| o.opperation = 't'}
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
          orders = [repay, sell]
        when HoldStatus::SELL
          orders = [repay, buy]
        end
        orders.flatten!
        orders.each {|o| o.opperation = 'l'}
        orders.each {|o| o.force = true}
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

  def transact?
    @codes.each do |code|
      next if @orders.find{|o| o.code == code and o.orderd?} 
      next if @boards.find{|b| b.code == code}
      return false
    end
    return true
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
      p ["b " + board[o.code][0].buy.to_s, 
         "o " + o.price.to_s,
         "s " + board[o.code][0].sell.to_s,
         o.code, 
      ].join(' ')
      raise OrderUndefinedCodeError if not board.key? o.code
      idx = @codes.index o.code
      tick = @ticks[idx]
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

class Normal < Player

  def buy
    validate_board
    result = []
    board1 = @boards.find {|b| b.code == @codes[0] }
    result << Order::Buy.new(
      code: @codes[0],
      price: board1.buy + @ticks[0],
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
      price: board1.sell - @ticks[0],
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
        order.price = board.sell - @ticks[0]
      when :sell
        order.price = board.buy + @ticks[0]
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
    all = Minute.closes(nil, nil, code: @codes[0], count: 1000)
    to = Time.now.strftime('%Y%m%d')
    if HoldStatus.current.nil?
      return OrderStatus.current = OrderStatus::PENDING
    end
    if all.length < 500
      return OrderStatus.current = OrderStatus::PENDING
    end
    b = board[@codes[0]][0]
    s = Minute.new
    s.key   = CodeTime.new(@codes[0], to, Time.now.strftime('%H%M'))
    if OrderStatus.current == OrderStatus::BUY
      s.value = b.sell
      all << s
    elsif OrderStatus.current == OrderStatus::SELL
      s.value = b.buy
      all << s
    end
    stocks = all[-200..-1]
    mx = 0
    vmx= 0
    step = 80.step(180,10)
    step.each do |length|
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
    bols = all[-400..-1].bol(400)
    if HoldStatus.current == HoldStatus::BUY
      if bols[-1].value < -3
        return OrderStatus.current = OrderStatus::LOSS_CUT
      end
    elsif HoldStatus.current == HoldStatus::SELL
      if bols[-1].value > 3
        return OrderStatus.current = OrderStatus::LOSS_CUT
      end
    end
    last_order = Order.last_orders(@codes[0])[0]
    if last_order.loss_cut?
      bol = all.bol(400)
      sub = Stocks[*bol.find_all {|a| a.key.date + a.key.time > last_order.sdate + last_order.stime }]
      if last_order.buy? and bols[-1].value > 2
        if sub.find{|a| a.value < 1.5}
          return OrderStatus.current = OrderStatus::SELL
        end
      elsif last_order.sell? and bols[-1].value < -2
        if sub.find{|a| a.value > -1.5}
          return OrderStatus.current = OrderStatus::BUY
        end
      end
    else
      if bols[-1].value < -0.5
        if b.buy_volume > @volumes[0] * 50
          return OrderStatus.current = OrderStatus::BUY
        end
      elsif bols[-1].value > 0.5 
        if b.sell_volume > @volumes[0] * 50
          return OrderStatus.current = OrderStatus::SELL
        end
      end
      if HoldStatus.current == HoldStatus::BUY
        return OrderStatus.current = OrderStatus::BUY
      elsif HoldStatus.current == HoldStatus::SELL
        return OrderStatus.current = OrderStatus::SELL
      end
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
    uncontracteds = @orders.find_all {|o| o.orderd? and o.code.to_s == @codes[0].to_s }
    if uncontracteds.length == 0
      return AssembleStatus.current = AssembleStatus::COMPLETE
    end
    uncontracteds.each do |o|
      tick = @ticks[0]
      if o.buy?
        if @boards[0].buy > o.price
          return AssembleStatus.current = AssembleStatus::BE_CONTRACTED
        end
      elsif o.sell?
        if @boards[0].sell < o.price
          return AssembleStatus.current = AssembleStatus::BE_CONTRACTED
        end
      end
    end
    AssembleStatus.current = AssembleStatus::PROCESSING
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

end


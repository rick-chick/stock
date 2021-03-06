#coding: utf-8
class Order
  attr_accessor :id, :code, :force, :date, :price, :volume, :contracted_price, 
    :contracted_volume,:status, :edit_url, :cancel_url, :no, :edited, :opperation, :cancel, :next, :repeat

  def self.create(hash, is_buy, is_repay)
    if is_repay
      if is_buy
        Order::Buy::Repay.new(hash) 
      else
        Order::Sell::Repay.new(hash) 
      end
    else
      if is_buy
        Order::Buy.new(hash) 
      else
        Order::Sell.new(hash)
      end
    end
  end

  def initialize(hash = {})
    hash = {edited: false, 
            force: false, 
            id: nil,
            no: nil,
            date: Time.now,
            status: Status::Orderd.new, 
            edit_url: nil,
            cancel_url: nil,
            opperation: ' ',
            cancel: false, 
            next: nil, 
            repeat: 10, 
    }.merge(hash)
    @id = hash[:id]
    @no = hash[:no].to_s
    @code = hash[:code].to_s
    @date = hash[:date]
    @price = hash[:price].to_f
    @volume = hash[:volume].to_i
    @contracted_price = hash[:contracted_price].to_f
    @contracted_volume = hash[:contracted_volume].to_i
    @force = hash[:force]
    @edit_url = hash[:edit_url]
    @cancel_url = hash[:cancel_url]
    @status = hash[:status]
		@opperation = hash[:opperation]
		@cancel = hash[:cancel]
		@next = hash[:next]
		@repeat = hash[:repeat]
  end

  def orderd? 
    @status.kind_of? Status::Orderd or 
      @status.kind_of? Status::Edited or
      @status.kind_of? Status::Dealing
  end

  def contracted?
    @status.kind_of? Status::Contracted
  end

  def new?
    not @edited
  end

  def price=(price)
    return if @price == price
    @price = price.to_f
  end

  def volume=(volume)
    return if @volume == volume
    @volume = volume.to_i
  end

  def force=(force)
    return if @force == force
    @force = force
  end

  def status=(status)
    return if @status == status
    @status = status
  end

  def buy?
    self.kind_of? Order::Buy
  end

  def sell?
    self.kind_of? Order::Sell
  end

  def repay?
    self.kind_of? Order::Sell::Repay or
      self.kind_of? Order::Buy::Repay
  end

	def loss_cut?
		@opperation == 'l'
	end

  def cancel=(flg)
    @cancel = flg
    @repeat = 0 if flg
  end

  def repeat?
    @repeat >= 0
  end

  def each
    o = self
    continue = true
    while o and continue
      yield o
      if o.status.kind_of? Status::Denied
        continue = false
        o.repeat -= 1
      end
      o = o.next
    end
    continue
  end

  def denied?
    @status.kind_of? Status::Denied
  end

  def self.last_orders(code)
    sql =<<-SQL
      select orders.no
           , orders.code
           , orders.date
           , orders.force
           , orders.price
           , orders.volume
           , orders.trade_kbn
           , orders.opperation
        from orders
        join (select *
                from orders 
               where code = $1
            order by date desc 
               limit 1 
             ) latest
          on orders.id = latest.id
    order by orders.code
           , orders.trade_kbn
    SQL
    result = []
    Db.conn.exec(sql, [code]).each do |r|
      hash = {
        no: r["no"],
        code: r["code"],
        date: r["date"],
        force: r["force"],
        price: r["price"],
        volume: r["volume"],
        opperation: r["opperation"],
      }
      is_buy = r["trade_kbn"].to_i == 0 or r["trade_kbn"].to_i == 2
      is_repay = r["trade_kbn"].to_i > 1
      is_buy = (not is_buy) if is_repay
      result << Order.create(hash, is_buy, is_repay)
    end
    result
  rescue => ex
    puts ex.message
    puts ex.backtrace
    []
  end

	def stime
		@date[-8..-7] + @date[-5..-4]
	end

	def sdate
		@date[0..3] + @date[5..6] + @date[8..9]
	end

  def insert
    sql =<<-SQL
      insert into orders (
        no,
        code, 
        date,
        force,
        price,
        volume,
        trade_kbn,
        opperation,
        updated
      ) values ( $1, $2, $3, $4, $5, $6, $7, $8, current_timestamp)
    SQL
    trade_kbn = case self
                when Buy::Repay
                  2
                when Sell::Repay
                  3
                when Buy
                  0
                when Sell
                  1
                end
    params = [
      @no,
      @code,
      @date,
      @force,
      @price,
      @volume,
      trade_kbn.to_s,
      @opperation,
    ]
    Db.conn.exec(sql, params)
    1
  rescue => ex
    puts ex.message
    puts ex.backtrace
    0
  end

  def <=>(other)
    a = case self
    when Order::Buy
      0
    when Order::Sell
      1
    when Order::Buy::Repay
      2
    when Order::Sell::Repay
      3
    end

    b = case other
    when Order::Buy
      0
    when Order::Sell
      1
    when Order::Buy::Repay
      2
    when Order::Sell::Repay
      3
    end

    a <=> b
  end

  class Buy < Order
    class Repay < Buy; end
  end

  class Sell < Order
    class Repay < Sell; end
  end
end


#coding: utf-8
class Order
  attr_accessor :id, :code, :force, :date, :price, :volume, :contracted_price, 
    :contracted_volume,:status, :edit_url, :cancel_url, :no, :edited

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
  end

  def orderd?
    @status.kind_of? Status::Orderd or @status.kind_of? Status::Edited
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

  def self.last_orders
    sql =<<-SQL
      select orders.no
           , orders.code
           , orders.date
           , orders.force
           , orders.price
           , orders.volume
           , orders.trade_kbn
        from orders
        join (select *
                from orders 
               where force = false 
            order by date desc 
               limit 1 
             ) latest
          on orders.date = latest.date
    order by orders.code
           , orders.trade_kbn
    SQL
    result = []
    Db.conn.exec(sql).each do |r|
      hash = {
        no: r["no"],
        code: r["code"],
        date: r["date"],
        force: r["force"],
        price: r["price"],
        volume: r["volume"],
      }
      is_buy = r["trade_kbn"].to_i == 0 or r["trade_kbn"].to_i == 2
      is_repay = r["trade_kbn"].to_i > 1
      result << Order.create(hash, is_buy, is_repay)
    end
    result
  rescue => ex
    p ex
    []
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
        updated
      ) values ( $1, $2, $3, $4, $5, $6, $7, current_timestamp)
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
    ]
    Db.conn.exec(sql, params)
    1
  rescue => ex
    p ex
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


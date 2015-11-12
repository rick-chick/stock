#coding: utf-8
class Order
  attr_accessor :id, :code, :force, :date, :price, :volume, :contracted_price, :contracted_volume,:status, :edit_url, :cancel_url, :edit_price, :edit_volume

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
    hash = {edit_price: false, 
            edit_volume: false, 
            force: false, 
            id: nil,
            date: Time.now,
            status: Status::Orderd.new, 
            edit_url: nil,
            cancel_url: nil,
    }.merge(hash)
    @id = hash[:id]
    @code = hash[:code]
    @date = hash[:date]
    @price = hash[:price]
    @volume = hash[:volume]
    @contracted_price = hash[:contracted_price]
    @contracted_volume = hash[:contracted_volume]
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
    (not @edit_price and not @edit_volume) or @edit_url.nil?
  end

  def price=(price)
    return if @price == price
    @edit_price= true
    @price = price
  end

  def volume=(volume)
    return if @volume == volume
    @edit_volume = true
    @volume = volume
  end

  def force=(force)
    return if @force == force
    @edit_price = true
    @force = force
  end

  def status=(status)
    return if @status == status
    @edit_price = false
    @edit_volume = false
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

  class Buy < Order
    class Repay < Buy; end
  end

  class Sell < Order
    class Repay < Sell; end
  end
end


#encoding: utf-8
class Board
  attr_accessor :code, :price, :sell, :buy, :sell_volume, :buy_volume, 
    :open, :open_time, :high, :high_time, :low, :low_time, 
    :time, :volume, :tick, :diff, :rate, :closed

  def initialize(hash = {})
    hash = {time: Time.now
    }.merge(hash)
    @code = hash[:code].to_s
    @price = hash[:price].to_f
    @time = hash[:time]
    @diff = hash[:diff].to_f
    @rate = hash[:rate].to_f
    @open = hash[:open].to_f
    @open_time = hash[:open_time]
    @high = hash[:high].to_f
    @high_time = hash[:high_time]
    @low = hash[:low].to_f
    @low_time = hash[:low_time]
    @sell = hash[:sell].to_f
    @sell_volume = hash[:sell_volume].to_f
    @buy = hash[:buy].to_f
    @buy_volume = hash[:buy_volume].to_f
    @volume = hash[:volume].to_f
    @tick = hash[:tick].to_f
    @closed = hash[:closed]
  end

  def closed?
    @closed
  end
end


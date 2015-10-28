#encoding: utf-8
class Board
  attr_accessor :code, :price, :sell, :buy, :sell_volume, :buy_volume, 
    :open, :open_time, :high, :high_time, :low, :low_time, 
    :time, :volume, :tick, :diff, :rate

  def initialize(hash = {})
    hash = {time: Time.now
    }.merge(hash)
    @code = hash[:code]
    @price = hash[:price]
    @time = hash[:time]
    @diff = hash[:diff]
    @rate = hash[:rate]
    @open = hash[:open]
    @open_time = hash[:open_time]
    @high = hash[:high]
    @high_time = hash[:high_time]
    @low = hash[:low]
    @low_time = hash[:low_time]
    @sell = hash[:sell]
    @sell_volume = hash[:sell_volume]
    @buy = hash[:buy]
    @buy_volume = hash[:buy_volume]
    @volume = hash[:volume]
    @tick = hash[:tick]
  end
end


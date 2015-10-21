#encoding: utf-8
class Board
  attr_accessor :code, :price, :sell_price, :buy_price, :sell_volume, :buy_volume, :time

  def initialize(hash = {})
    hash = {time: Time.now
    }.merge(hash)
    @code = hash[:code]
    @price = hash[:price]
    @sell_price = hash[:sell_price]
    @buy_price = hash[:buy_price]
    @sell_volume = hash[:sell_volume]
    @buy_volume = hash[:buy_bolume]
    @time = hash[:time]
  end
end


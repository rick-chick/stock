#coding: utf-8
class Hand
  attr_accessor :code, :trade_kbn, :kouza_kbn, :price, :order_price, :volume, :profit, :asset, :date, :kigen, :url

  def initialize(hash = {})
    @code = hash[:code].to_s
    @trade_kbn = hash[:trade_kbn]
    @kouza_kbn = hash[:kouza_kbn]
    @price = hash[:price].to_f
    @order_price = hash[:order_price].to_f
    @volume = hash[:volume].to_i
    @profit = hash[:profit].to_f
    @asset = hash[:asset].to_f
    @date = hash[:date]
    @kigen = hash[:kigen]
    @url = hash[:url]
  end

  def to_o
    hash = {}
    hash[:code] = @code
    hash[:price] = @price
    hash[:volume] = @volume
    hash[:edit_url] = @url
    Order.create(
      hash,
      @trade_kbn == :buy,
      true,
    )
  end
end

#encoding: utf-8
class Player

  attr_accessor :boards, :hands, :orders

  def create_order
    if wait_contract?
      modifications
    else
      decisions
    end
  end

  def wait_contract?
    not @orders.find {|order| not order.contracted?}.nil?
  end

  def decisions
  end

  def modifiactions
    uncontracteds = @orders.find_all {|order| not order.contracted?}
    results = []
    uncontracteds.each do |order|
      stock = stocks.find {|stock| order.code == stock.code}
      if order.kind_of? Order::Buy and order.price > stock.buy_price
        order.force = true
        results << order
      elsif order.kind_of? Order::Sell and order.price < stock.buy_price
        order.force = true
        results << order
      end
    end
    results
  end
end

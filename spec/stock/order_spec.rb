require File.expand_path(File.dirname(__FILE__)) + '/../spec_helper.rb'

describe "Order" do

  describe "#insert" do

    let(:order) do
      Order::Sell.new(
        code: 1301,
        date: Time.now,
        no: 999,
        force: false,
        price: 35.3,
        volume: 50,
      )
    end
    after{ Db.conn.exec("delete from orders where code='#{order.code}' and date='#{order.date}' and no='#{order.no}'") }
    specify {expect(order.insert).to eq 1}
  end

  describe "#each" do

    let(:order) do
      order = Order::Sell.new(
        code: 1301,
        date: Time.now,
        no: 50,
        force: false,
        price: 35.3,
        volume: 50,
        cancel: true,
      )
      order.next = Order::Buy.new(
        code: 1301,
        date: Time.now,
        no: 51,
        force: false,
        price: 45.3,
        volume: 50,
      )
      order
    end

    specify do 
      order.repeat = 0
      count = 0
      success = order.each do |o|
        o.status = Status::Orderd.new
        count += 1
      end
      expect(count).to eq 2
      expect(success).to eq true
    end

    specify do 
      count = 0
      success = order.each do |o|
        count += 1
        o.status = Status::Denied.new
        o.repeat = -1
      end
      expect(success).to eq false
      expect(count).to eq 1
    end

  end
end

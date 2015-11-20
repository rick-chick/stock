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

end

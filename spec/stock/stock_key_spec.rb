require File.expand_path(File.dirname(__FILE__)) + '/../spec_helper.rb'

describe "StockKey" do

  describe "#insert" do
    let(:stock_key){StockKey.new}
    after{ Db.conn.exec("delete from stock_keys where id = #{stock_key.id}") }
    specify {expect(stock_key.insert).to eq 1}
  end

  describe "#delete" do
    let(:stock_key){StockKey.new}
    before{ stock_key.insert }
    specify {expect(stock_key.delete).to eq 1}
  end

end

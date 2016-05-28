require File.expand_path(File.dirname(__FILE__)) + '/../spec_helper.rb'

describe "Pair" do
  pending ""

  after do 
    Db.conn.exec(<<-SQL
      delete from stock_keys a 
      where exists( select * 
                      from pair_times b 
                     where a.id = b.stock_key_id 
                       and b.code1 = 'test1'
                       and b.code2 = 'test2') 
    SQL
    )
  end

  describe "insert" do
    context "when some data inserted" do

      it "result must be 1" do
        pair = Pair.new
        pair.close = 1500
        pair.volume = 0
        pair.key = PairTime.new("test1", "test2", Time.now)
        ret = pair.insert
        expect(ret).to be(1)
      end
    end
  end

  describe "read" do
    it "should be success" do
      ret = Pair.read("20151001", "20151201", "close")
      expect(ret.kind_of? Array).to be true
    end

    context "when specic data is inserted" do
      let(:target) {Time.new(2015, 11, 2, 10, 0, 0)}
      let(:close) { 1530 }
      let(:volume) { 10 }

      before do 
        pair = Pair.new
        pair.close = close
        pair.volume = volume
        pair.key = PairTime.new("test1", "test2", target)
        pair.insert
      end

      it "count should be 1" do
        stocks = Pair.read(target, target, "close")
        p stocks
        expect(stocks.length).to eq 1
      end

      it "close should be valid" do
        stocks = Pair.read(target, target, "close")
        expect(stocks[0].value).to eq close
      end

      it "volume should be valid " do
        stocks = Pair.read(target, target, "volume")
        expect(stocks[0].value).to eq volume
      end
    end
  end
end

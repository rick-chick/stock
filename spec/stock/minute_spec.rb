require File.expand_path(File.dirname(__FILE__)) + '/../spec_helper.rb'

describe "Minute" do

  after do 
    Db.conn.exec(<<-SQL
      delete from stock_keys a 
      where exists( select * 
                      from code_times b 
                     where a.id = b.stock_key_id 
                       and b.code = 'test') 
    SQL
    )
  end
  describe "#read" do

    before do
      time = Time.new(2011,10,1)
      4.times do
        s = Stock.new
        s.key = CodeTime.new('test', time.strftime('%Y%m%d'), time.strftime('%H%M'))
        s.close = 1000
        s.high = 1000
        s.low = 1000
        s.open = 1000
        s.insert
        time += 60 * 60 * 24
      end
    end

    specify do
      from = "20111001"
      to = "20111002"
      hash = {code: 'no such code'}
      expect(Minute.read(from ,to, "close", hash).length).to eq 0
    end

    specify do
      from = "20111001"
      to = "20111002"
      hash = {code: 'test'}
      expect(Minute.read(from ,to, "close", hash).length).to eq 2
    end

    specify do
      from = "20111001"
      to = "20111022"
      hash = {code: 'test'}
      expect(Minute.read(from ,to, "close", hash).length).to eq 4
    end

    specify do
      from = nil
      to = nil
      hash = {code: 'test', 
              count: 2}
      closes = Minute.read(from ,to, "close", hash)
      expect(closes.length).to eq 2
      expect(closes[-1].date).to eq "20111004"
    end
  end
end

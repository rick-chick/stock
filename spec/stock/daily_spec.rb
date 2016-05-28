require File.expand_path(File.dirname(__FILE__)) + '/../spec_helper.rb'

describe "Daily" do

  after do 
    Db.conn.exec(<<-SQL
      delete from stock_keys a 
      where exists( select * 
                      from code_dates b 
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
        s.key = CodeDate.new('test', time.strftime('%Y%m%d'))
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
      expect(Daily.read(from ,to, "close", hash).length).to eq 0
    end

    specify do
      from = "20111001"
      to = "20111002"
      hash = {code: 'test'}
      expect(Daily.read(from ,to, "close", hash).length).to eq 2
    end

    specify do
      from = "20111001"
      to = "20111022"
      hash = {code: 'test'}
      expect(Daily.read(from ,to, "close", hash).length).to eq 4
    end
  end
end

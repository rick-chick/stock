require File.expand_path(File.dirname(__FILE__)) + '/../spec_helper.rb'

describe "Stock" do

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

  describe "#insert" do
    let(:obj) do
      ret = Minute.new
      ret.key = CodeTime.new('test')
      ret.high = 1000
      ret.low = 900
      ret.open = 910
      ret.close = 990
      ret.volume = 500000
      ret
    end
    specify {expect(obj.insert).to eq 1}
  end

  describe "#update" do
    let(:obj) do
      ret = Minute.new
      ret.key = CodeTime.new('test')
      ret.high = 1000
      ret.low = 900
      ret.open = 910
      ret.close = 990
      ret.volume = 500000
      ret
    end
    specify do 
      obj.insert
      obj.close = 970
      expect(obj.update).to eq 1
    end
  end
end

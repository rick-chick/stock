require File.expand_path(File.dirname(__FILE__)) + '/../spec_helper.rb'

describe "PairTime" do

  describe "#insert" do
    let(:pair_time){PairTime.new('test1','test2',Time.now)}
    after{ Db.conn.exec("delete from stock_keys where id = #{pair_time.id}") }
    specify {expect(pair_time.insert).to eq 1}
  end

  describe "#delete" do
    let(:pair_time){PairTime.new('test1', 'test2',Time.now)}
    before{ pair_time.insert }
    specify {expect(pair_time.delete).to eq 1}
  end

end

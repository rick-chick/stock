require File.expand_path(File.dirname(__FILE__)) + '/../spec_helper.rb'

describe "CodeTime" do

  describe "#insert" do
    let(:code_time){CodeTime.new('test')}
    after{ Db.conn.exec("delete from stock_keys where id = #{code_time.id}") }
    specify {expect(code_time.insert).to eq 1}
  end

  describe "#delete" do
    let(:code_time){CodeTime.new('test')}
    before{ code_time.insert }
    specify {expect(code_time.delete).to eq 1}
  end

end

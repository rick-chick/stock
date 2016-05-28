require File.expand_path(File.dirname(__FILE__)) + '/../spec_helper.rb'

describe "CodeDate" do

  describe "#insert" do
    let(:code_date){CodeDate.new('test')}
    after{ Db.conn.exec("delete from stock_keys where id = #{code_date.id}") }
    specify {expect(code_date.insert).to eq 1}
  end

  describe "#delete" do
    let(:code_date){CodeDate.new('test')}
    before{ code_date.insert }
    specify {expect(code_date.delete).to eq 1}
  end

end

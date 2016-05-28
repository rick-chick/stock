require File.expand_path(File.dirname(__FILE__)) + '/../spec_helper.rb'

describe "CodeTime" do

  let(:obj){CodeTime.new('test')}
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
    specify {expect(obj.insert).to eq 1}
  end

  describe "#delete" do
    before{ obj.insert }
    specify {expect(obj.delete).to eq 1}
  end

  describe "#id" do
    context "inserted object" do
      before{ obj.insert }
      specify {expect(obj.id).not_to eq nil}
    end

    context "object is not in db" do
      specify {expect(obj.id).to eq nil}
    end

    context "object is in db" do
      let(:new_obj) { CodeTime.new('test') }
      before do
        obj.insert
        new_obj.date = obj.date
        new_obj.time = obj.time
      end
      specify {expect(new_obj.id).to eq obj.id}
    end
  end
end

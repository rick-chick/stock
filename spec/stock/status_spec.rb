require File.expand_path(File.dirname(__FILE__)) + '/../spec_helper.rb'

describe "Status" do

  describe "#insert" do
    let(:status){Status.new}
    after{ Db.conn.exec("delete from statuses where id = #{status.id}") }
    specify {expect(status.insert).to eq 1}
  end

  describe "#delete" do
    let(:status){Status.new}
    before{ status.insert }
    specify {expect(status.delete).to eq 1}
  end

end

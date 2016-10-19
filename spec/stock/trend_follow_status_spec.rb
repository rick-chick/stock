require File.expand_path(File.dirname(__FILE__)) + '/../spec_helper.rb'

describe "TrendFollowStatus" do

  let(:obj){TrendFollowStatus.new('test')}
  after do 
    Db.conn.exec(<<-SQL
      delete from statuses a 
      where exists( select * 
                      from trend_follow_statuses b 
                     where a.id = b.status_id 
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
      let(:new_obj) { TrendFollowStatus.new('test') }
      before do
        obj.insert
        new_obj.code = obj.code
        new_obj.time = obj.time
      end
      specify {expect(new_obj.id).to eq obj.id}
    end
  end

  describe ".current_status_of" do
    let(:obj2){ TrendFollowStatus.new('test')}

    specify do 
      obj.follow = false
      obj.direction = TrendFollowStatus::BUY
      obj.insert
      sleep 1
      obj2.follow = true
      obj2.direction = TrendFollowStatus::SELL
      obj2.insert
      trend = TrendFollowStatus.current_status_of('test')
      expect(trend.follow).to eq true 
      expect(trend.buy?).to eq false
      expect(trend.sell?).to eq true
    end

    specify do 
      obj.follow = false
      obj.insert
      trend = TrendFollowStatus.current_status_of('test')
      expect(trend.follow).to eq false
      expect(trend.buy?).to eq nil
      expect(trend.sell?).to eq nil
    end

    specify do 
      expect(TrendFollowStatus.current_status_of('test')).to eq nil
    end
  end
end

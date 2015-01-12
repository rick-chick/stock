require File.expand_path(File.dirname(__FILE__)) + '/../spec_helper.rb'

describe "K2Metric" do

  describe "each" do

    context "when two nodes have full link" do
      let(:metric) { Bayesian::K2Metric.new(2) }
      specify do
        i = 0
        metric.each do |node|
          case i
          when 0
            expect(node.rank).to eq 0
            expect(node.parents.length).to eq 0
          when 1
            expect(node.rank).to eq 0
            expect(node.parents.length).to eq 1
            expect(node.parents[0]).to eq 1
          when 2
            expect(node.rank).to eq 1
            expect(node.parents.length).to eq 0
          end
          i+=1
        end
        expect(i).to eq 3
      end
    end

    context "when three nodes have full link" do
      let(:metric) { Bayesian::K2Metric.new(3) }
      specify do
        i = 0
        metric.each do |node|
          case i
          when 0
            expect(node.rank).to eq 0
            expect(node.parents.length).to eq 0
          when 1
            expect(node.rank).to eq 0
            expect(node.parents.length).to eq 1
            expect(node.parents[0]).to eq 1
          when 2
            expect(node.rank).to eq 0
            expect(node.parents.length).to eq 2
            expect(node.parents[0]).to eq 1
            expect(node.parents[1]).to eq 2
          when 3
            expect(node.rank).to eq 1
            expect(node.parents.length).to eq 0
          when 4
            expect(node.rank).to eq 1
            expect(node.parents.length).to eq 1
            expect(node.parents[0]).to eq 2
          when 5
            expect(node.rank).to eq 2
            expect(node.parents.length).to eq 0
          end
          i+=1
        end
        expect(i).to eq 6
      end
    end
  end

end

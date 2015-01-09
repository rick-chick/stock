require File.expand_path(File.dirname(__FILE__)) + '/../spec_helper.rb'

describe "K2Metric" do

  describe ".construct_nodes" do

    context "when one node is given" do
      let(:nodes) { Baysian::K2Metric.new(1).construct_nodes }
      specify { expect(nodes.length).to eq 1 }
      specify { expect(nodes[0].rank).to eq 0 }
      specify { expect(nodes[0].parent_ranks.length).to eq 0 }
    end

    context "when two nodes are given" do
      let(:nodes) { Baysian::K2Metric.new(2).construct_nodes }
      specify { expect(nodes.length).to eq 2 }
      specify { expect(nodes[0].rank).to eq 0 }
      specify { expect(nodes[0].parent_ranks.length).to eq 1 }
      specify { expect(nodes[0].parent_ranks[0]).to eq 1 }

      specify { expect(nodes[1].rank).to eq 1 }
      specify { expect(nodes[1].parent_ranks.length).to eq 0 }
    end

    context "when three nodes are given" do
      let(:nodes) { Baysian::K2Metric.new(3).construct_nodes }
      specify { expect(nodes.length).to eq 5 }

      specify { expect(nodes[0].rank).to eq 0 }
      specify { expect(nodes[0].parent_ranks.length).to eq 1 }
      specify { expect(nodes[0].parent_ranks[0]).to eq 1 }

      specify { expect(nodes[1].rank).to eq 0 }
      specify { expect(nodes[1].parent_ranks.length).to eq 2 }
      specify { expect(nodes[1].parent_ranks[0]).to eq 1 }
      specify { expect(nodes[1].parent_ranks[1]).to eq 2 }

      specify { expect(nodes[2].rank).to eq 0 }
      specify { expect(nodes[2].parent_ranks.length).to eq 1 }
      specify { expect(nodes[2].parent_ranks[0]).to eq 2 }

      specify { expect(nodes[3].rank).to eq 1 }
      specify { expect(nodes[3].parent_ranks.length).to eq 1 }
      specify { expect(nodes[3].parent_ranks[0]).to eq 2 }

      specify { expect(nodes[4].rank).to eq 2 }
      specify { expect(nodes[4].parent_ranks.length).to eq 0 }
    end
  end

end

require File.expand_path(File.dirname(__FILE__)) + '/../spec_helper.rb'

describe "K2Metric" do

  describe ".construct_nodes" do

    context "when one node is given" do
      let(:nodes) { Baysian::K2Metric.construct_nodes(1) }
      specify { expect(nodes.length).to eq 1 }
      specify { expect(nodes[0].rank).to eq 0 }
      specify { expect(nodes[0].parents.length).to eq 0 }
    end

    context "when two nodes are given" do
      let(:nodes) { Baysian::K2Metric.construct_nodes(2) }
      specify { expect(nodes.length).to eq 2 }
      specify { expect(nodes[0].rank).to eq 0 }
      specify { expect(nodes[0].parents.length).to eq 1 }
      specify { expect(nodes[0].parents[0]).to eq 1 }

      specify { expect(nodes[1].rank).to eq 1 }
      specify { expect(nodes[1].parents.length).to eq 0 }
    end

    context "when three nodes are given" do
      let(:nodes) { Baysian::K2Metric.construct_nodes(3) }
      specify { expect(nodes.length).to eq 4 }

      specify { expect(nodes[0].rank).to eq 0 }
      specify { expect(nodes[0].parents.length).to eq 1 }
      specify { expect(nodes[0].parents[0]).to eq 1 }

      specify { expect(nodes[1].rank).to eq 0 }
      specify { expect(nodes[1].parents.length).to eq 1 }
      specify { expect(nodes[1].parents[0]).to eq 2 }

      specify { expect(nodes[2].rank).to eq 0 }
      specify { expect(nodes[2].parents.length).to eq 2 }
      specify { expect(nodes[2].parents[0]).to eq 1 }
      specify { expect(nodes[2].parents[1]).to eq 2 }

      specify { expect(nodes[3].rank).to eq 1 }
      specify { expect(nodes[3].parents.length).to eq 1 }
      specify { expect(nodes[3].parents[0]).to eq 2 }
    end
  end

end

require File.expand_path(File.dirname(__FILE__)) + '/../spec_helper.rb'

describe "node" do

  describe "links_from" do

    context "when link is line" do
      let(:node3) do 
        node = Baysian::Node.new(2) 
      end
      let(:node2) do
        node = Baysian::Node.new(1) 
        node.parents << 2
        node
      end
      let(:node1) do
        node = Baysian::Node.new(0)
        node.parents << 1
        node
      end
      let(:tree) do
        t = []
        t << node1
        t << node2
        t << node3
      end
      let(:links) { node1.links_from([], tree) }

      specify { expect(links.length).to eq 3}
      specify { expect(links).to eq [[1,2],[2,3],[3]]}
    end
  end

end

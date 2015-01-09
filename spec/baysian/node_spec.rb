require File.expand_path(File.dirname(__FILE__)) + '/../spec_helper.rb'

describe "node" do

  describe "links_from" do

    context "when link is line" do
      let(:node3) do
        node = Baysian::Node.new(2)
      end
      let(:node2) do
        node = Baysian::Node.new(1)
        node.parent_ranks << 2
        node
      end
      let(:node1) do
        node = Baysian::Node.new(0)
        node.parent_ranks << 1
        node
      end
      let(:tree) do
        t = []
        t << node1
        t << node2
        t << node3
      end

      specify "links pertern count should be 1" do
        count = 0
        node1.links([], tree) do |link|
          count += 1
        end
        expect(count).to eq 1
      end

    end

    context "when two head link" do
      let(:node3) do
        node = Baysian::Node.new(2)
      end
      let(:node2) do
        node = Baysian::Node.new(1)
        node.parent_ranks << 2
        node
      end
      let(:node1) do
        node = Baysian::Node.new(0)
        node.parent_ranks << 1
        node.parent_ranks << 2
        node
      end
      let(:tree) do
        t = []
        t << node1
        t << node2
        t << node3
      end

      specify "links pertern count should be 2" do
        count = 0
        node1.links([], tree) do |link|
          count += 1
        end
        expect(count).to eq 2
      end

    end
  end

end

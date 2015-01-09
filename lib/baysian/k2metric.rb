module Baysian
  class K2Metric

    def self.construct_nodes(nodes_count)
      raise "nodes_count must be greater than zero" if nodes_count < 1
      @nodes = []
      (2**nodes_count-1).times do |n|
        patern = "%0#{nodes_count}d" % (n+1).to_s(2)
        next if patern =~ /^0+10*$/
        child = nil
        patern.chars.reverse.each_with_index do |bit, rank|
          next if bit == "0"
          if child
            child.parent_ranks << rank
          else
            @nodes << child = Baysian::Node.new(rank)
          end
        end
      end
      @nodes.each { |node| node.parent_ranks.sort! }
      @nodes.sort!
    end

    def self.links(&block)
      @nodes.select {|node| node.rank == 0}.each do |child|
        child.links([], @nodes, &block)
      end
    end

  end
end

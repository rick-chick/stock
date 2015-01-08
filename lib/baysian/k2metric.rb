module Baysian
  class K2Metric

    def self.construct_nodes(nodes_count)
      raise "nodes_count must be greater than zero" if nodes_count < 1

      result = []
      (2**nodes_count-1).times do |n|
        patern = "%0#{nodes_count}d" % (n+1).to_s(2)
        next if patern =~ /^0+10*$/
        child = nil
        patern.chars.reverse.each_with_index do |bit, rank|
          next if bit == "0"
          if child
            child.parents << rank
          else
            result << child = Baysian::Node.new(rank)
          end
        end
      end
      result.each { |node| node.parents.sort! }
      result.sort!
    end

    def self.recursive_each
      @nodes.select {|node| node.rank == 0}.each do |child|
        yield child.link_from([])
      end
    end

  end
end

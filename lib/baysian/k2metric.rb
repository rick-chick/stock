module Baysian
  class K2Metric

    def self.construct_nodes(nodes_count)
      raise "nodes_count must be greater than zero" if nodes_count < 1
      result = []
      nodes_count.times {|n| result << Baysian::Node.new(n)}
      (2**(nodes_count-1)).times do |pattern|
        next if pattern =~ /10+/
        node = nil
        pattern.to_s(2).chars.reverse.each_with_index do |bit, rank|
          next if bit == "0" 
          if node 
            node.parents << rank
          else
            node = result.find {|target| target.rank = rank}
          end
        end
      end
      result.sort!
    end

  end
end

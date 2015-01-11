module Bayesian
  class K2Metric

    def initialize(num_nodes)
      @num_nodes = num_nodes
      @nodes     = []
    end

    attr_accessor :nodes

    def each(&block)
      (0...@num_nodes).each {|n| @nodes << Bayesian::Node.new(n)}
      best = 0
      @nodes.each do |child|
        score = block.call(child)
        best  = [score, best].max
        (child.rank+1...@num_nodes).each do |parent_rank|
          child.parents << parent_rank
          score = block.call(child)
          if score > best
            best = score
          else
            child.parents.delete parent_rank
          end
        end
      end
    end
  end
end

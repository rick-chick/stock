module Baysian
  class Node 
    
    attr_accessor :parent_ranks, :rank

    def initialize(rank)
      @parent_ranks   = []
      @rank           = rank
    end

    def <=>(other)
      (@rank <=> other.rank).nonzero? or @parent_ranks <=> other.parent_ranks
    end

    def to_s
      <<-STRING
        rank:    #{@rank} "
        parents: #{@parent_ranks.join(" ")}
      STRING
    end

    def links(link, tree, &block)
      if @parent_ranks.length == 0 
        block.call(link << [@rank])
      else
        link << [@rank] + @parent_ranks
        @parent_ranks.each do |parent_rank|
          tree.select {|n| n.rank == parent_rank}.each do |node|
            node.links(link.dup, tree, &block)
          end
        end
      end
    end

  end
end

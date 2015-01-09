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

    def links_from(link, tree)
      if @parent_ranks.length == 0 
        link << [@rank]
      else
        link << [@rank] + @parent_ranks
        @parent_ranks.each do |parent_rank|
          tree.select do |node| 
            node.rank == parent_rank
          end.each do |node|
            node.links_from(link, tree)
          end
        end
      end
    end

  end
end

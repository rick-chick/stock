module Baysian
  class Node 
    
    attr_accessor :parents, :rank

    def initialize(rank)
      @parents  = []
      @rank     = rank
    end

    def <=>(other)
      (@rank <=> other.rank).nonzero? or @parents <=> other.parents
    end

    def to_s
      <<-STRING
        rank:    #{@rank} "
        parents: #{@parents.join(" ")}
      STRING
    end

    def links_from(link, tree)
      if @parents.length == 0 
        link << [@rank]
      else
        link << [@rank] + @parents
        @parents.each do |parent_rank|
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

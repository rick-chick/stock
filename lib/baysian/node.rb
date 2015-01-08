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

  end
end

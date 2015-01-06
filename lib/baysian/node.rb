module Baysian
  class Node 
    
    attr_accessor :parents, :rank

    def initialize(rank)
      @parents  = []
      @rank     = rank
    end

    def <=>(other)
      if @rank <=> other.rank
        @rank <=> other.rank
      else
        @parents <=> other.parents
      end
    end

    def to_s
      <<-STRING
        rank:    #{@rank} "
        parents: #{@parents.join(" ")}
      STRING
    end

  end
end

module Bayesian
  class Node 

    def initialize(rank)
      @rank    = rank
      @parents = []
    end

    attr_accessor :rank, :parents

  end
end

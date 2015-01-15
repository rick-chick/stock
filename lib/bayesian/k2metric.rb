module Bayesian
  class K2Metric

    def initialize(num_nodes)
      @num_nodes = num_nodes
      @nodes     = []
    end

    attr_accessor :nodes

    def each(&block)
      (0...@num_nodes).each {|n| @nodes << Bayesian::Node.new(n)}
      @nodes.each do |child|
        best = -Float::MAX
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

    #
    # @ijk [Hash]     cpt 
    # @q_i [Integer]  number of node i's parents
    # @r_i [Integer]  number of node i's states
    #
    #key   is child and parents value set 
    #value is count of the child and parents value set
    #
    #child1:    node1 is child
    #parent2:   node2 is parent
    #child1(0): child1 have 0's value
    #
    #1) child have some parents
    # key                                value
    #  [child1(0), parent2(0),  ...  ]    32
    #  [child1(0), parent2(1), ...   ]    11
    #  [child1(1), parent2(0), ...   ]    2
    # 
    #2) child have no parents
    # key                                value
    #  [child1(0)]                        46
    #  [child1(1)]                        2
    #  [child1(2)]                        12
    #
    #note 
    # cpt(ijk) can take only one child node and some parents of the child
    # ie. i is fixed. j,k are vary
    def score(ijk, r_i)
      ij      = {}
      ret = 0
      ijk.each do |key, n_ijk|
        p_i = key[1..-1]
        ij[p_i] ||= 0
        ij[p_i] += n_ijk
        ret += Math.lgamma(1+n_ijk)[0]
      end
      ij.each do |key, n_ij|
        ret += Math.lgamma(r_i)[0] - Math.lgamma(r_i+n_ij)[0]
      end
      ret
    end
  end
end

module Basian
  class Node < Array
    
    attr_accessor :count, :parents, :children, :states

    def initalize(states)
      @parents  = Node.new
      @children = Node.new
      @states   = states
    end

  end
end

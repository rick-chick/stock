module Cluster
  class Cluster 

    attr_accessor :nodes, :center

    def initialize
      @nodes  = Node.new
      @center = Node.new
      @@i   ||= 0
      @@i    += 1
      @number = @@i
    end

    def add(node)
      @nodes << node
    end

    def release_nodes
      @nodes.clear
    end

    def move_center
      return if @nodes.length == 0
      @center.clear
      @nodes.each do |node|
        node.each_with_index do |x, i|
          @center[i] ||= 0
          @center[i] += x.to_f
        end
      end
      @center.collect! {|x| x / @nodes.length }
    end

    def to_s
      <<-STR
      #{self.class.name}#{@number}: #{@nodes.length}
        max:    #{max}
        center: #{center}
        min:    #{min}
      STR
    end

    def max
      @nodes.transpose.map {|vec| vec.max}
    end

    def min
      @nodes.transpose.map {|vec| vec.min}
    end

    def enclose?(node)
      max, min = self.max, self.min
      node.each_with_index do |x, i|
        return false if x > max[i]
        return false if x < min[i]
      end
      true
    end
  end
end

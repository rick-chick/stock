class Cluster 

  attr_accessor :nodes, :center

  def initialize
    @nodes  = Node.new
    @center = Node.new
    @@i ||= 0
    @@i += 1
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

  def max
    @nodes.max
  end

  def min
    @nodes.min
  end

  def to_s
    @nodes.inject("#{self.class.name}#{@number}:") {|s, node| s += "#{node} " }
  end
end


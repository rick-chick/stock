module Cluster
  class KMeans

    attr_accessor :clusters, :nodes

    def initialize(input_data, num_of_clusters)
      @nodes    = node_of(input_data) 
      @clusters = (1..num_of_clusters).map {Cluster.new}
      @nodes.each_with_index do |array, i|
        @clusters[Random.rand(num_of_clusters)].add(array)
      end
    end

    def clusterize(other_data = nil)
      @nodes += node_of(other_data) if other_data
      begin
        @clusters.each do |cluster|
          cluster.move_center
          cluster.release_nodes
        end
        @nodes.each do |node|
          node.join_to_nearest(@clusters)
        end
      end until not any_node_move?
      @clusters.each {|cluster| cluster.move_center}
    end

    def node_of(obj)
      if obj.kind_of?(Node) 
        obj
      elsif obj.kind_of?(Array)
        Node.new(*obj)
      elsif obj.kind_of?(Numeric)
        Node[Node[obj]]
      else
        raise <<-MSG 
          InputData must to be Node or Array.
          Array like be [[1,2], [1,3], [4,3]].
          if you use Node, you can use Node.new(*array).
          this array like be above too.
        MSG
      end
    end

    def any_node_move?
      @nodes.each do |node|
        return true if node.moved?
      end
      false
    end

  end
end

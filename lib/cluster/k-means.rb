class KMeans

  attr_accessor :clusters, :nodes

  def clusterize(input_data, num_of_clusters)
    @nodes    = input_data
    @clusters = (1..num_of_clusters).map {Cluster.new}
    @nodes.each_with_index do |array, i|
      @clusters[i % num_of_clusters].add(array)
    end
    begin
      @clusters.each do |cluster|
        cluster.move_center
        cluster.release_nodes
      end
      @nodes.each do |node|
        node.join_to_nearest(@clusters)
      end
    end until any_node_move?
    @clusters.each {|cluster| cluster.move_center}
  end

  def any_node_move?
    @nodes.each do |node|
      return true if node.moved?
    end
    false
  end

end

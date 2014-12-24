class KMeans

  attr_accessor :clusters, :nodes, :centers

  def clusterize(input_data, num_of_clusters)

    @nodes    = input_data
    @clusters = num_of_clusters.times.to_a.map {Cluster.new}
    @nodes.each_with_index do |array, i|
      @clusters[i % num_of_clusters].add(array)
    end

    prev    = []
    while prev != @centers
      @clusters.each do |cluster|
        cluster.move_center
        cluster.release_nodes
      end
      @nodes.each do |node|
        node.join_to_nearest(@clusters)
      end
      prev     = @centers
      @centers = @clusters.map {|cluster| cluster.center}
    end
  end

end

module Cluster
  class Node < Array

    attr_accessor :cluster, :prev

    def initialize(*array)
      array.map do |node|
        self << Node[*node]
      end
    end

    def distance_to(other)
      distance = 0
      each_with_index do |x, i|
        distance += (x - other[i]) ** 2
      end
      Math.sqrt(distance)
    end

    def join_to_nearest(clusters)
      min_distance    = Float::MAX
      nearest_cluster = nil
      clusters.each do |cluster|
        distance = cluster.center.distance_to(self)
        if distance < min_distance
          min_distance    = distance
          nearest_cluster = cluster
        end
      end
      self.cluster = nearest_cluster
    end

    def cluster=(cluster)
      prev     = @cluster
      @cluster = cluster
      @moved   = (@cluster != prev)
      @cluster.add(self)
    end

    def moved?
      @moved
    end

  end
end

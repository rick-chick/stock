require File.expand_path(File.dirname(__FILE__)) + '/require.rb'

to      = Date.latest
from    = to.prev(3000)
closes  = Daily.closes(from ,to, code:1301)
log     = closes.fill_blank.log
kmeans  = Cluster::KMeans.new(log.values, 4)
kmeans.clusterize

puts kmeans.clusters

grd_log = log.calc(1) do |stocks|
  kmeans.clusters.find do |cluster|
    cluster.enclose?(Cluster::Node[stocks[0].value])
  end
end



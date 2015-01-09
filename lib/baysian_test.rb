require File.expand_path(File.dirname(__FILE__)) + '/require.rb'

to      = Date.latest
from    = to.prev(3000)
closes  = Daily.closes(from ,to, code:1301)
log     = closes.fill_blank.log
cluster = Cluster::KMeans.new(log.values, clusters = 4)
baysian = Baysian::K2Metric.new(nodes_count = 3)

cluster.clusterize
grd_log = log.calc(1) do |stocks|
  cluster.clusters.find do |cluster|
    cluster.enclose?(Cluster::Node[stocks[0].value])
  end
end

baysian.construct_nodes
baysian.links do |link|
  link.each do |joint|
    nodes = joint.map do |rank|
      rank > 0 ? grd_log : grd_log.delay(rank)
    end
    ctt = {}
    Stocks.merge(*nodes) do |stocks|
      key = stocks.map {|stock| stock.value.center}
      next if key.include? nil
      ctt[key] ||= 0
      ctt[key] += 1
    end
  end
end

require File.expand_path(File.dirname(__FILE__)) + '/require.rb'

to       = Date.latest
from     = to.prev(3000)
closes   = Daily.closes(from ,to, code:1301)
log      = closes.fill_blank.log
kmeans   = Cluster::KMeans.new(log.values, 4)
bayesian = Bayesian::K2Metric.new(3)

kmeans.clusterize
grd_log = log.calc(1) do |stocks|
  kmeans.clusters.find do |cluster|
    cluster.enclose?(Cluster::Node[stocks[0].value])
  end
end

bayesian.each do |node|
  delays = node.parents.map do |parent_rank|
    grd_log.delay(parent_rank)
  end
  cpt = {}
  Stocks.merge(grd_log, *delays) do |stocks|
    key = stocks.map {|stock| stock.value.center}
    next if key.include? nil
    cpt[key] ||= 0
    cpt[key] += 1
  end
  Bayesian::K2Metric.score(cpt)
end

puts bayesian.nodes


require File.expand_path(File.dirname(__FILE__)) + '/require.rb'

to        = Date.latest
from      = to.prev(3000)
closes    = Daily.closes(from ,to, code: 9984)
log       = closes.fill_blank.log
grid_size = t3
cluster   = Cluster::KMeans.new(log.values, grid_size)
bayesian  = Bayesian::K2Metric.new(10)

cluster.clusterize
grd_log = log.calc(1) do |stocks|
  cluster.clusters.find do |cluster|
    cluster.enclose?(Cluster::Node[stocks[0].value])
  end
end

bayesian.each do |node|
  delays = node.parents.map do |parent_rank|
    grd_log.delay(parent_rank)
  end
  cpt = {}
  Stocks.merge(grd_log.delay(node.rank), *delays) do |stocks|
    key = stocks.map {|stock| stock.value.center if stock}
    next if key.include? nil
    cpt[key] ||= 0
    cpt[key] += 1
  end
  score = bayesian.score(cpt, grid_size)
  puts "#{node.rank} #{node.parents} #{score}"
  score
end

bayesian.nodes.each do |node|
  puts node.rank
  node.parents.each do |parent|
    puts " #{parent}"
  end
end

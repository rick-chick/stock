require File.expand_path(File.dirname(__FILE__)) + '/require.rb'

to        = Date.latest
from      = to.prev(3500)
closes    = Daily.closes(from ,to, code: 9984)
log       = closes.fill_blank.log
grid_size = 4
cluster   = Cluster::KMeans.new(log.values, grid_size)
bayesian  = Bayesian::K2Metric.new(20)

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

puts "scores"
total_scoer = 0
bayesian.nodes.each do |node|
  puts "#{node.rank} #{node.score}"
  total_scoer += node.score if node.score
end
puts total_scoer

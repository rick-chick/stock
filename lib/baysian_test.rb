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

nodes_count = 3
(nodes_count-1).times do |i|
  child = i > 0 ? grd_log.delay(i) : grd_log

  (i+1..2**(nodes_count-i-1)-1).each do |j|
    puts ""
    puts i
    
    parents = []
    j.to_s(2).chars.reverse.each_with_index do |bit, k|
      next if not bit == "1" 
      parents << grd_log.delay(k+1) 
      puts k+1
    end

    ctt = {}
    Stocks.merge(child, *parents) do |stocks|
      key = stocks.map do |stock|
        next if not stock
        stock.value.center
      end
      ctt[key] ||= 0
      ctt[key] += 1
    end

    ctt.each do |key, value|
      next if not value
      puts "#{key} #{value}"
    end
  end
end

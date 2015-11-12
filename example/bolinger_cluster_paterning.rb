dir = File.dirname(File.expand_path(__FILE__))
require "#{dir}/../lib/stock"

learning = 2000
to       = Date.latest
from     = to.prev(learning)
codes    = Code.tradable_codes(to.prev(1), 250)

bol_length   = (10..100)
cluster_size = (5..20)
log_size     = (1..50)
log          = Log.new('bolinger_cluster_paterning/test')

def synchronize
  while true
    File.open('lock', 'w') do |file|
      return yield if file.flock(File::LOCK_EX|File::LOCK_NB)
    end
  end
end

codes.each {|code| log.puts code} 
Parallel.each(codes) do |code|
  begin
    closes = synchronize do 
      Daily.adjusteds(from ,to, code: code)
    end
    raise "#{code} length is too short" if not closes.length > 1500

    bols  = []
    dates = []
    (100...closes.length).each do |i|
      item = []
      bol_length.each do |l|
        item << closes[i-l..i].bol(l).last.value
      end
      bols  << item
      dates << closes[i].date
    end

    logs = []
    log_size.each do |l|
      logs[l] = closes.log(l)
    end

    max_sum          = 0
    max_log_size     = nil
    max_cluster_size = nil
    max_sums         = nil
    max_cluster      = nil

    cluster_size.each do |cs|
      cluster = Cluster::KMeans.new(bols, cs)
      cluster.clusterize

      sums    = {}
      counts  = {}
      bols.each_with_index do |bol, i|
        center = cluster.clusters.find do |c|
          c.enclose?(bol)
        end.center

        sums[center]   ||= []
        counts[center] ||= []
        log_size.each do |l|
          next if not logs[l][i+l]
          sums[center][l]   ||= 0
          counts[center][l] ||= 0
          sums[center][l]   += logs[l][i+l].value
          counts[center][l] += 1
        end
      end

      sums.each do |center, values|
        log_size.each do |l|
          sum = values[l] / counts[center][l]
          if sum > max_sum
            max_sum          = sum
            max_log_size     = l
            max_cluster_size = cs
            max_sums         = sums
            max_cluster      = cluster
          end
        end
      end
    end

    center = max_cluster.clusters.find do |c|
      c.enclose?(bols.last)
    end.center

    synchronize do
      log.puts code 
      log.puts max_sum
      log.puts max_log_size
      log.puts max_cluster_size
      log.puts max_sums[center][max_log_size]
    end

  rescue => ex
    log.puts ex.message
    log.puts ex.backtrace.to_s
  end
end

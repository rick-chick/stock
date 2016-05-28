#encoding: utf-8
class Board
  attr_accessor :code, :price, :sell, :buy, :sell_volume, :buy_volume, 
    :open, :open_time, :high, :high_time, :low, :low_time, 
    :time, :volume, :tick, :diff, :rate, :closed

  def initialize(hash = {})
    hash = {time: Time.now
    }.merge(hash)
    @code = hash[:code].to_s
    @price = hash[:price].to_f
    @time = hash[:time]
    @diff = hash[:diff].to_f
    @rate = hash[:rate].to_f
    @open = hash[:open].to_f
    @open_time = hash[:open_time]
    @high = hash[:high].to_f
    @high_time = hash[:high_time]
    @low = hash[:low].to_f
    @low_time = hash[:low_time]
    @sell = hash[:sell].to_f
    @sell_volume = hash[:sell_volume].to_i
    @buy = hash[:buy].to_f
    @buy_volume = hash[:buy_volume].to_i
    @volume = hash[:volume].to_i
    @tick = hash[:tick].to_f
    @closed = hash[:closed]
  end

  def closed?
    @closed
  end

	def self.select(code)
    params = [code]
    sql = <<-SQL
      select  code, price, sell, buy, sell_volume, buy_volume, 
							open, open_time, high, high_time, low, low_time, 
							time, volume, tick, diff, rate, closed
        from  boards
       where  code = $1
    SQL
    ret = []
    Db.conn.exec(sql, params).each do |row|
      b = Board.new
			b.code = row["code"].to_s
			b.price = row["price"].to_f
			b.time = row["time"]
			b.diff = row["diff"].to_f
			b.rate = row["rate"].to_f
			b.open = row["open"].to_f
			b.open_time = row["open_time"]
			b.high = row["high"].to_f
			b.high_time = row["high_time"]
			b.low = row["low"].to_f
			b.low_time = row["low_time"]
			b.sell = row["sell"].to_f
			b.sell_volume = row["sell_volume"].to_i
			b.buy = row["buy"].to_f
			b.buy_volume = row["buy_volume"].to_i
			b.volume = row["volume"].to_i
			b.tick = row["tick"].to_f
			b.closed = row["closed"]
			ret << b
    end
		ret
	end

	def upsert
		params = [@code, @price, @time, @diff,
							@rate, @open, @open_time, @high,
							@high_time, @low, @low_time, @sell,
							@sell_volume, @buy, @buy_volume, @volume,
							@tick, @closed,
		]
    sql = <<-SQL
      insert into boards (code, price, time, diff,
													rate, open, open_time, high,
													high_time, low, low_time, sell,
													sell_volume, buy, buy_volume, volume,
													tick, closed) 
									values ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, 
													$11, $12, $13, $14, $15, $16, $17, $18)
							on conflict on constraint boards_pkey
						do update set price = $2 , time = $3 , diff = $4 , rate = $5 , open = $6
												, open_time = $7 , high = $8 , high_time = $9 , low = $10
												, low_time = $11 , sell = $12 , sell_volume = $13 , buy = $14
												, buy_volume = $15 , volume = $16 , tick = $17 , closed = $18
		SQL
    Db.conn.exec(sql, params)
		1
	rescue => ex
		p ex
		0
	end
end


class Stock 

  attr_accessor :options, :key, :value, :open, :high, :low, :close, :adjusted, :volume

  def initialize(key = nil, *value)
    @key     = key
    @value   = value[0]
    @options = value[1] 
  end

  def subkey
    @key.subkey
  end

  def subkey=(subkey)
    @key.subkey = subkey
  end

  def to_s
    "#{@key}  #{@value}"
  end

  def <=>(o)
    @key <=> o.key
  end

  def id
    @key.id
  end

  def id=(id)
    @key.id = id
  end

  def self.closes(from, to, hash ={})
    read(from, to, "close", hash)
  end

  def self.opens(from, to, hash={})
    read(from, to, "open", hash)
  end

  def self.highs(from, to, hash={})
    read(from, to, "high", hash)
  end

  def self.lows(from, to, hash={})
    read(from, to, "low", hash)
  end

  def self.volumes(from ,to, hash={})
    read(from, to, "volume", hash)
  end

  def self.adjusteds(from, to, hash={})
    read(from, to, "adjusted", hash)
  end

  def insert
    Db.conn.exec("begin")
    raise "key insert missed" if @key.insert == 0
    params = []
    params << @key.id
    params << @open.to_f
    params << @high.to_f
    params << @low.to_f
    params << @close.to_f
    params << @adjusted.to_f
    params << @volume.to_i
    sql =<<-SQL
      insert into stocks
      (stock_key_id, open, high, low, close, adjusted, volume, updated)
      values
      ($1, $2, $3, $4, $5, $6, $7, current_timestamp)
    SQL
    Db.conn.exec(sql, params)
    Db.conn.exec("commit")
    1
  rescue PG::UniqueViolation => ex
    Db.conn.exec("rollback")
    0
  rescue => ex
    Db.conn.exec("rollback")
    p self
    puts ex.backtrace
    puts ex.message
    0
  end

  def update
    sql = <<-SQL
      update stocks 
      set
      (open, high, low, close, adjusted, volume, updated)
      =
      ($2, $3, $4, $5, $6, $7, current_timestamp)
      where stock_key_id = $1
    SQL
    params = []
    raise "code_dates not found" if not @key.id
    params << @key.id.to_i
    params << @open.to_f
    params << @high.to_f
    params << @low.to_f
    params << @close.to_f
    params << @adjusted.to_f
    params << @volume.to_i
    Db.conn.exec(sql, params)
    1
  rescue => ex
    p self
    puts ex.backtrace
    puts ex.message
    0
  end
end

class Daily < Stock

  def code
    @key.code
  end

  def code=(code)
    @key.code = code
  end

  def date
    @key.date
  end

  def date=(date)
    @key.date = date
  end

  def self.blank_instances(code, date)
    CodeDate.blank_instances(code, date).map do |code_date|
      Daily.new(code_date, nil)
    end
  end

  def self.read(from ,to, column, hash = {})
    if not hash.kind_of? Hash 
      raise "Stock.read(from, to, column, options) options must be hash"
    end
    params = [from, to]
    conditions = ""
    if hash.key?(:code) 
      params << hash[:code]
      conditions = "and  code_dates.code = $3"
    end

    sql = <<-SQL
      select  stocks.stock_key_id
            , stocks.#{column}
            , code_dates.code
            , code_dates.date
        from  stocks
            , code_dates
       where   code_dates.date  >=  $1
          and  code_dates.date  <=  $2
          and  stocks.stock_key_id = code_dates.stock_key_id
            #{conditions}
      order by code, date
    SQL

    stocks = Stocks.new
    Db.conn.exec(sql, params).each do |row|
      s = Daily.new
      s.key   = CodeDate.new(row["code"], row["date"])
      s.id    = row["stock_key_id"]
      s.value = row[column].to_f
      stocks << s
    end
    stocks
  end

end

class Minute < Stock

  def code
    @key.code
  end

  def code=(code)
    @key.code = code
  end

  def date
    @key.date
  end

  def date=(date)
    @key.date = date
  end

  def time
    @key.date
  end

  def time=(time)
    @key.time = time
  end

  def self.blank_instances(code, date)
    CodeTime.blank_instances(code, date).map do |code_minute|
      Minute.new(code_minute, nil)
    end
  end

  def self.read(from ,to, column, hash = {})
    if not hash.kind_of? Hash 
      raise "Stock.read(from, to, column, options) options must be hash"
    end
    conditions = ""
    if hash.key?(:count) 
      params = [hash[:count]]
      if hash.key?(:code) 
        params << hash[:code]
        conditions = "and  code_times.code = $2"
      end
      sql = <<-SQL
        select  stocks.stock_key_id
              , stocks.#{column}
              , code_times.code
              , code_times.date
              , code_times.time
          from  stocks
              , code_times
         where  code_times.stock_key_id = stocks.stock_key_id
              #{conditions}
        order by code, date desc, time desc
        limit  $1 offset 0
      SQL
      stocks = Stocks.new
      Db.conn.exec(sql, params).each do |row|
        s = Minute.new
        s.key   = CodeTime.new(row["code"], row["date"], row["time"])
        s.id    = row["stock_key_id"]
        s.value = row[column].to_f
        stocks.unshift s
      end
      stocks
    else
      params = [from, to]
      if hash.key?(:code) 
        params << hash[:code]
        conditions = "and  code_times.code = $3"
      end
      sql = <<-SQL
        select  stocks.stock_key_id
              , stocks.#{column}
              , code_times.code
              , code_times.date
              , code_times.time
          from  stocks
              , code_times
         where  code_times.date  >=  $1
         and  code_times.date  <=  $2
           and  code_times.stock_key_id = stocks.stock_key_id
              #{conditions}
        order by code, date, time
      SQL
      stocks = Stocks.new
      Db.conn.exec(sql, params).each do |row|
        s = Minute.new
        s.key   = CodeTime.new(row["code"], row["date"], row["time"])
        s.id    = row["stock_key_id"]
        s.value = row[column].to_f
        stocks << s
      end
      stocks
    end
  end
end

class Pair < Stock

  attr_accessor :time, :code1, :code2

  def code1
    @key.code1
  end

  def code1=(code)
    @key.code1 = code
  end

  def code2
    @key.code2
  end

  def code2=(code)
    @key.code2 = code
  end

  def time
    @key.time
  end

  def time=(time)
    @key.time = time
  end

  def self.blank_instances(code, date)
    CodeTime.blank_instances(code, date).map do |code_minute|
      Minute.new(code_minute, nil)
    end
  end

  def self.read(from ,to, column, hash = {})
    if not hash.kind_of? Hash 
      raise "Stock.read(from, to, column, options) options must be hash"
    end
    from = from.strftime('%Y%m%d%H%M%S') if from.kind_of? Time
    to = to.strftime('%Y%m%d%H%M%S') if to.kind_of? Time
    params = [from, to]
    conditions = ""
    if hash.key?(:code1) then
      params << hash[:code1]
      conditions = "and  pair_times.code1 = $3"
    end
    if hash.key?(:code2) then
      params << hash[:code2]
      conditions = "and  pair_times.code2 = $4"
    end

    sql = <<-SQL
      select  stocks.stock_key_id
            , stocks.#{column}
            , pair_times.code1
            , pair_times.code2
            , pair_times.time
        from  stocks
            , pair_times
       where  pair_times.time  >=  to_timestamp($1, 'yyyymmddhh24miss')
         and  pair_times.time  <=  to_timestamp($2, 'yyyymmddhh24miss')
         and  pair_times.stock_key_id = stocks.stock_key_id
            #{conditions}
      order by code1, code2,time
    SQL

    stocks = Stocks.new
    Db.conn.exec(sql, params).each do |row|
      s = Pair.new
      s.key   = PairTime.new(row["code1"], row["code2"], row["time"])
      s.id    = row["stock_key_id"]
      s.value = row[column].to_f
      stocks << s
    end
    stocks
  end

  def self.select_equilibrium_price(code1, code2, to, count)
    params = [code1, code2, to, count]
    sql = <<-SQL
      select  stocks.stock_key_id
            , stocks.low
            , pair_times.code1
            , pair_times.code2
            , pair_times.time
        from  stocks
            , pair_times
       where  pair_times.time  <=  $3
         and  pair_times.stock_key_id = stocks.stock_key_id
         and  pair_times.code1 = $1
         and  pair_times.code2 = $2
         and  stocks.high = stocks.low
    order by  code1, code2,time desc
       limit  $4 offset 0
    SQL

    stocks = Stocks.new
    Db.conn.exec(sql, params).each do |row|
      s = Pair.new
      s.key   = PairTime.new(row["code1"], row["code2"], Time.parse(row["time"]))
      s.id    = row["stock_key_id"]
      s.value = row["low"].to_f
      stocks.unshift s
    end
    stocks
  end
end

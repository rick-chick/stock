class Stock 

  attr_accessor :key, :value, :options, :code, :value, :date, :open, :high, :low, :close, :adjusted, :volume, :id

  def initialize(key = nil, *value)
    @key     = key
    @value   = value[0]
    @options = value[1] 
  end

  def subkey
    date
  end

  def subkey=(subkey)
    @date = subkey
  end

  def code=(code)
    @code = code
    @key  ||= "            "
    @key[0..3] = code
  end

  def code
    @code ||= @key[0..3]
  end

  def date
    @date ||= @key[4..11]
  end

  def date=(date)
    @date = date
    @key  ||= "            "
    @key[4..11] = date
  end

  def to_s
    "#{@code}  #{@date}  #{@value}"
  end

  def <=>(o)
    self.key <=> o.key
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
		params = []
		params << @open.to_f
    params << @high.to_f
    params << @low.to_f
    params << @close.to_f
		params << @adjusted.to_f
		params << @volume.to_i
		sql =<<-SQL
      insert into stocks
      (open, high, low, close, adjusted, volume, updated)
      values
      ($1, $2, $3, $4, $5, $6, current_timestamp)
    SQL
    Db.conn.exec(sql, params)
    Db.conn.exec("select lastval() id").each do |row|
			@id = row["id"]
		end
		code_date = CodeDate.new
		code_date.code = @code
		code_date.date = @date
		code_date.id   = @id
		raise "code_dates already exists" if code_date.insert == 0 
		Db.conn.exec("commit")
		1
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
			where id = $1
    SQL
    params = []
		@id ||= CodeDate.id(@code, @date)
		raise "code_dates not found" if not @id
		params << @id.to_i
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
		p ex.backtrace
		puts ex.message
    0
  end

  def self.read(from ,to, column, hash = {})
    params = [from, to]
    conditions = ""
    if hash.key?(:code) then
      params << hash[:code]
      conditions = "and  code_dates.code = $3"
    end

    sql = <<-SQL
      select  stocks.#{column}
            , code_dates.code
            , code_dates.date
        from  stocks
				    , code_dates
       where   code_dates.date  >=  $1
          and  code_dates.date  <=  $2
					and  stocks.id = code_dates.id
              #{conditions}
      order by code, date
    SQL

    stocks = Stocks.new
    Db.conn.exec(sql, params).each do |row|
      s = Stock.new
      s.code  = row["code"]
      s.date  = row["date"]
      s.value = row[column].to_f
      stocks << s
    end
    stocks
  end

end


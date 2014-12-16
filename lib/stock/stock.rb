class Stock 
  attr_accessor :key, :value, :options, :code, :value, :date

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

  def self.read(from ,to, column, hash = {})
    params = [from, to]
    conditions = ""
    if hash.key?(:code) then
      params << hash[:code]
      conditions = "and  code = $3"
    end

    sql = <<-SQL
      select  #{column}
            , code
            ,  date
        from  stocks
       where   date  >=  $1
          and  date  <=  $2
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


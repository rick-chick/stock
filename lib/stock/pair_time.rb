class PairTime

  attr_accessor :code1, :code2, :time, :id

  def initialize(code1, code2, time)
    @code1 = code1.to_s
    @code2 = code2.to_s
    self.time = time
  end

  def time=(time)
    if time.kind_of? String 
      if not time.length == 14
        @time = Time.new(time)
      else
        raise "time must be yyyymmdHHMMSS or time format"
      end
    elsif time.kind_of? Time
      @time = time
    else
      raise "time must be yyyymmdHHMMSS or time format"
    end
  end

  def subkey
    @time.strftime('%Y%m%d%H%M%S')
  end

  def subkey=(subkey)
    @time = subkey[-14..-1]
  end

  def <=>(o)
    to_s <=> o.to_s
  end

  def to_s
    @key ||= @code1 + @code2 + @time.strftime('%Y%m%d%H%M%S')
  end

  def id
    return @id if @id
    sql = <<-SQL
      select id 
        from pair_times
       where code1 = $1
         and code2 = $2
         and time  = $3
    SQL
    params = []
    params << @code1.to_s
    params << @code2.to_s
    params << @time
    Db.conn.exec(sql, params).each do |row|
      return @id = row["id"]
    end
    nil
  end

  def insert
    sql = <<-SQL
      insert into pair_times
      (id, code1, code2, time, updated)
      values
      ($1, $2, $3, $4, current_timestamp)
    SQL
    params = []
    params << @id.to_i
    params << @code1.to_s
    params << @code2.to_s
    params << @time
    Db.conn.exec(sql, params)
    1
  rescue PG::UniqueViolation => ex
    0
  rescue => ex
    p self
    puts ex.message
    p ex.backtrace
    0
  end
end

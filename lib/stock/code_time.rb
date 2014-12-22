class CodeTime < CodeDate

  attr_accessor :time

  def initialize(code, date, time)
    super(code, date)
    @time = time
    @time ||= "    "
  end

  def subkey
    @subkey ||= @date + @time
  end

  def subkey=(subkey)
    @subkey = subkey[-12..-1]
  end

  def to_s
    @key ||= @code + @date + @time
  end

  def id(code, date, time)
    return @id if @id
    sql = <<-SQL
    select id 
      from code_time
     where code   = $1
       and date   = $2
       and time   = $3
    SQL
    params = []
    params << code.to_s
    params << date.to_s
    params << time.to_s
    Db.conn.exec(sql, params).each do |row|
      return @id = row["id"]
    end
    nil
  end

  def insert
    sql = <<-SQL
      insert into code_times
      (id, code, date, time, updated)
      values
      ($1, $2, $3, $4, current_timestamp)
    SQL
    params = []
    params << @id.to_i
    params << @code.to_s
    params << @date.to_s
    params << @time.to_s
    Db.conn.exec(sql, params)
    1
  rescue => ex
    p self
    puts ex.message
    p ex.backtrace
    0
  end

end

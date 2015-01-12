class CodeDate

  attr_accessor :code, :date, :id

  def self.blank_instances(code, date)
    [CodeDate.new(code, date)]
  end

  def initialize(code = nil, date = nil)
    @code = code.to_s
    @date = date.to_s
    @code ||= "        "
    @date ||= "        "
  end

  def subkey
    @date
  end

  def subkey=(subkey)
    @date = subkey[-8..-1]
  end

  def <=>(o)
    to_s <=> o.to_s
  end

  def to_s
    @key ||= @code + @date
  end

  def id
    return @id if @id
    sql = <<-SQL
      select id 
        from code_dates
       where code = $1
         and date = $2
    SQL
    params = []
    params << @code.to_s
    params << @date.to_s
    Db.conn.exec(sql, params).each do |row|
      return @id = row["id"]
    end
    nil
  end

  def insert
    sql = <<-SQL
      insert into code_dates
      (id, code, date, updated)
      values
      ($1, $2, $3, current_timestamp)
    SQL
    params = []
    params << @id.to_i
    params << @code.to_s
    params << @date.to_s
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

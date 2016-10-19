class TrendFollowStatus < Status

  BUY = true
  SELL = false

  attr_accessor :code, :follow, :direction

  def initialize(code = nil)
    super()
    @code = code or nil
    @direction = nil
  end

  def buy?
    @follow ? @direction == BUY : nil
  end

  def sell?
    @follow ? @direction == SELL : nil
  end

  def self.current_status_of(code)
    sql = <<-SQL
      select b.id
           , b.time
           , a.code
           , a.follow
           , a.direction
        from trend_follow_statuses a
           , statuses b
       where a.status_id = b.id
         and a.code = $1
    order by b.time desc
       limit 1 offset 0
    SQL
    params = []
    params << code.to_s
    Db.conn.exec(sql, params).each do |row|
      t = TrendFollowStatus.new(code)
      t.time = Time.new(row["time"])
      t.follow = row["follow"] == "t"
      t.direction = t.follow ? row["direction"] == "t" : nil
      return t
    end
    nil
  end

  def id
    return @id if @id
    sql = <<-SQL
      select status_id 
        from trend_follow_statuses a
           , statuses b
       where a.code = $1
         and b.time = $2
         and a.status_id = b.id
    SQL
    params = []
    params << @code.to_s
    params << @time
    Db.conn.exec(sql, params).each do |row|
      return @id = row["status_id"]
    end
    nil
  end

  def insert
    super
    sql = <<-SQL
      insert into trend_follow_statuses
      (status_id, code, follow, direction, updated)
      values
      ($1, $2, $3, $4, current_timestamp)
    SQL
    params = []
    params << @id.to_i
    params << @code.to_s
    params << @follow
    params << @direction
    Db.conn.exec(sql, params)
    1
  rescue PG::UniqueViolation => ex
    0
  rescue => ex
    p self
    puts ex.message
    puts ex.backtrace
    0
  end
end

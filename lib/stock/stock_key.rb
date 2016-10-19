class StockKey

  attr_accessor :id

  def insert
    sql = <<-SQL
      insert into stock_keys
      (updated)
      values
      (current_timestamp)
    SQL
    params = []
    Db.conn.exec(sql, params)
    Db.conn.exec("select lastval() id").each do |r|
      @id = r["id"]
    end
    1
  rescue PG::UniqueViolation => ex
    0
  rescue => ex
    p self
    puts ex.message
    puts ex.backtrace
    0
  end

  def delete
    sql = "delete from stock_keys where id = $1"
    params = [@id]
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

  def <=>(o)
    to_s <=> o.to_s
  end
end

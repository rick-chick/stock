class Split
  attr_accessor :code, :date, :before, :after

  def insert
    sql = <<-SQL
      insert into splits
      (code, date, before, after)
      values
      ($1, $2, $3, $4)
    SQL
    params = []
    params << @code.to_s
    params << @date.to_s
    params << @before.to_f
    params << @after.to_f
    Db.conn.exec(sql, params)
    1
  rescue => ex
    p self
    ex.backtrace
    0
  end

end

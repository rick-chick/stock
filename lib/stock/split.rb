class Split
  attr_accessor :code, :date, :before, :after, :id

  def insert
    sql = <<-SQL
      insert into splits
      (id, before, after, updated)
      select id, $3, $4, current_timestamp
        from code_dates
       where code = $1
         and date = $2
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
    puts ex.backtrace
    puts ex.message
    0
  end

end

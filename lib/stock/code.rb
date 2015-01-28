class Code

  def self.all
    sql = <<-SQL
      select  distinct code
        from  code_dates
      order by code
    SQL

    Db.conn.exec(sql).inject([]) do |result,row|
      result << row["code"]
    end
  end

  def self.have_some_trade_at(date)
    sql = <<-SQL
      select distinct code
        from code_dates
       where date = $1
      order by code
    SQL
    params = [date]
    Db.conn.exec(sql, params).inject([]) do |result,row|
      result << row["code"]
    end
  end

  def self.unit(code)
    sql =<<-SQL
      select   volume
      from (
        select volume
             , row_number() over (order by date desc) as row_num
          from stocks
					   , code_dates
         where code = $1
				   and code_dates.id   = stocks.id
       ) stocks
         where row_num < 10
    SQL
    params = [code]
    rows = Db.conn.exec(sql, params)
    result = gcd_euclid(rows[0]["volume"], rows[0]["volume"])
    rows.each do |row|
      result = gcd_euclid(row["volume"], result)
    end
    return result
  end

  def self.tradable_codes(date, daily_minute_counte)
    sql =<<-SQL
      select code
        from (select code
                   , count(code) count
                from code_times
               where date = $1
            group by code
                   , date
             ) count
       where count > $2
    SQL
    params = [date, daily_minute_counte]
    rows = Db.conn.exec(sql, params)
    result = []
    rows.each do |row|
      result << row["code"]
    end
    return result
  end

  private
    def self.gcd_euclid(u, v)
      u = u.to_f
      v = v.to_f
      while (0 != v) do
        r = u % v
        u = v
        v = r
      end
      return u;
    end
end

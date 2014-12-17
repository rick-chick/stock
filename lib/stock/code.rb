class Code

  def self.all
    sql = <<-SQL
      select  code
        from  codes
      order by code
    SQL

    Db.conn.exec(sql).inject([]) do |result,row|
      result << row["code"]
    end
  end

  def self.unit(code)
    sql =<<-SQL
      select   volume
      from (
        select   volume
               ,row_number() over (order by date desc) as row_num
          from  stocks
         where  code = $1
       ) stocks
       where  row_num < 10
    SQL
    params = [code]
    rows = Db.conn.exec(sql, params)
    result = gcd_euclid(rows[0]["volume"], rows[0]["volume"])
    rows.each do |row|
      result = gcd_euclid(row["volume"], result)
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

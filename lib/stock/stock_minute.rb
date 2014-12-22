class StockMinute < Stock
  
  attr_accessor :time, :subkey

  def self.read(from ,to, column, hash = {})
    params = [from, to]
    conditions = ""
    if hash.key?(:code) then
      params << hash[:code]
      conditions = "and  code_times.code = $3"
    end

    sql = <<-SQL
      select  stocks.id
            , stocks.#{column}
            , code_times.code
            , code_times.date
            , code_times.time
        from  stocks
            , code_times
       where  code_times.date  >=  $1
         and  code_times.date  <=  $2
         and  code_times.id = stocks.id
              #{conditions}
      order by code, date, time
    SQL

    stocks = Stocks.new
    Db.conn.exec(sql, params).each do |row|
      s = StockMinute.new
      s.key   = CodeTime.new(row["code"], row["date"], row["time"])
      s.id    = row["id"]
      s.value = row[column].to_f
      stocks << s
    end
    stocks
  end
end

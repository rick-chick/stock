class Date

  @@dates = nil

  def self.all
    return @@dates if @@dates
    sql = <<-SQL
      select   distinct date
      from     code_dates
      order by date
    SQL

    @@dates = []
    Db.conn.exec(sql).each do |row|
      @@dates << row["date"].to_s
    end
    @@dates
  end

  def self.prev(date, length)
    h = all.select{|e| e < date}
    if h and h.length > 0 then
      h[-length]
    else
      all[0]
    end
  end
  
  def self.next(date, length)
    h = all.select{|e| e > date}
    if h and h.length > 0 and h.length >= length then
      h[length-1]
    else
      all.last
    end
  end

  def self.latest
    all.last
  end

  def self.now
    Date.today.strftime('%Y%m%d')
  end

  def self.latest_after_a_day
    (Date.parse(Date.latest) + 1).strftime("%Y%m%d")
  end

  def self.latest_of(code)
    sql = <<-SQL
      select  date 
      from    code_dates
      where   code = $1
      order by  date desc
      limit 1
    SQL
    Db.conn.exec(sql, [code]).each do |row|
      return row["date"].to_s
    end
  end

  def self.oldest_of(code)
    sql = <<-SQL
      select  date 
      from    code_dates
      where   code = $1
      order by  date 
      limit 1
    SQL
    Db.conn.exec(sql, [code]).each do |row|
      return row["date"].to_s
    end
  end
 
end

class String

  def next(length)
    Date.next(self, length)
  end

  def prev(length)
    Date.prev(self, length)
  end

  def up_to(last)
    return if self > last
    dates = Date.all.select do |e|
       self <= e and e <= last 
    end
    NArray[*dates].each do |date|
      yield date
    end
  end

  def month
    self[4..5]
  end

  def day
    self[6..7]
  end

  def year
    self[0..3]
  end
end

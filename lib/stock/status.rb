#coding: utf-8
class Status

  attr_accessor :id, :time

  class Orderd < Status; end
  class Cancel < Status; end
  class Contracted < Status; end
  class OutDated < Status; end
  class Denied < Status; end
  class Edited < Status; end
  class Dealing < Status; end

  def initialize
    @time = Time.now
  end

  def self.create(str)
    return Orderd.new if str =~ /注文済/ or str =~ /注文中/ or str =~ /内出来/ or 
      str =~ /予約済/ or str =~ /翌発待/ or str =~ /注文前/
    return Contracted.new if str =~ /約定済/ 
    return OutDated.new if str =~ /出来ズ/
    return Cancel.new if str =~ /取消済/ or str =~ /一部取/
    return Edited.new if str =~ /訂正済/ or str =~ /取消中/
		Dealing.new
  end

  def insert
    sql = <<-SQL
      insert into statuses
      (time, updated)
      values
      ($1, current_timestamp)
    SQL
    params = [@time]
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
    sql = "delete from statuses where id = $1"
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

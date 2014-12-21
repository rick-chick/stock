
class CodeDate

	attr_accessor :code, :date, :id

	def self.id(code, date)
    sql = <<-SQL
		select id 
      from code_dates
		 where code = $1
		   and date = $2
    SQL
    params = []
		params << code.to_s
		params << date.to_s
    Db.conn.exec(sql, params).each do |row|
			return row["id"]
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
  rescue => ex
		p self
		puts ex.message
		p ex.backtrace
		0
	end

end

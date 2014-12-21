class CreateCodeDates < ActiveRecord::Migration
  def up
		execute "create table code_dates (id bigint primary key, code varchar(8), date char(8), updated timestamp)"
		execute "create unique index code_date_index on code_dates (code, date)"
  end

  def down
		execute "drop table code_dates"
  end
end

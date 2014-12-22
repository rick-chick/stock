class CreateCodeTimesMigration < ActiveRecord::Migration
  def up
		execute <<-SQL
      create table code_times 
      (
        id bigint primary key
      , code varchar(8)
      , date char(8)
      , time char(4)
      , updated timestamp
      )
    SQL
		execute "create unique index code_time_index on code_times (code, date, time)"
  end

  def down
    execute "drop table code_times"
  end
end

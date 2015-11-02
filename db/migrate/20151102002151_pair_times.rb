class PairTimes < ActiveRecord::Migration
  def up
    execute "create table pair_times (id bigserial primary key, code1 varchar(8), code2 varchar(8), time timestamp, updated timestamp)"
		execute "create unique index pair_time_index on pair_times (code1, code2, time)"
  end

  def down
		execute "drop table pair_times"
  end
end

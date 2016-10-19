class CreateTrendFollowStatus < ActiveRecord::Migration
  def up
		execute "create table trend_follow_statuses( status_id bigint, code varchar(8) not null, follow boolean,  direction boolean, updated timestamp);"
		execute(<<-SQL
      alter table trend_follow_statuses
      add constraint fk_trend_follow_status_status_key 
      foreign key (status_id) 
      references statuses(id)
      on delete cascade
    SQL
    )
		execute "create unique index status_id_index on trend_follow_statuses(status_id)"
  end

  def down
		execute "drop table trend_follow_statuses"
  end
end

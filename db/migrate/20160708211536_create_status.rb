class CreateStatus < ActiveRecord::Migration
  def up
		execute "create table statuses ( id bigserial primary key, time timestamp not null ,updated timestamp default current_timestamp);"
  end

  def down
		execute "drop table statuses"
  end
end

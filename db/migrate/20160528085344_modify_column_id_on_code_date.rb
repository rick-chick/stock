class ModifyColumnIdOnCodeDate < ActiveRecord::Migration
  def up
		execute "create sequence code_dates_id_seq"
		execute "alter table code_dates alter column id set default nextval('code_dates_id_seq')"
		execute "alter sequence code_dates_id_seq owned by code_dates.id"
    select_all('select max(id) id from code_dates').each do |r|
      execute("select setval('code_dates_id_seq', #{r['id'].to_i+1})")
    end
  end

  def down
		execute "alter table code_dates alter column id type bigint primary key"
    execute "drop sequence code_dates_id_seq"
  end
end

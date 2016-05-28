class DataConvertPairTimes < ActiveRecord::Migration
  def up
		select_all('select * from pair_times').each do |r|
			execute('insert into stock_keys (updated) values (current_timestamp)')
			id = select_all('select lastval() id')[0]['id']
			execute("update pair_times set stock_key_id =#{id} where id = #{r['id']}")
			execute("update stocks set stock_key_id =#{id} where id = #{r['id']}")
		end
  end

	def down
		select_all('select * from pair_times').each do |r|
			execute("update pair_times set stock_key_id =null where id = #{r['id']}")
			execute("update stocks set stock_key_id =null where id = #{r['id']}")
		end
	end
end

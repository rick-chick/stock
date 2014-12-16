class Db
	@@conn 
	def self.conn
		@@conn ||= open
		status = @@conn.connect_poll
		if status != PGconn::CONNECTION_OK
			@@conn.close
			@@conn = open
		else
			@@conn
		end
	end

	def self.open
		PG::Connection.open(:user 			=> 'akishige',
												:password 	=> '135790',
												:dbname 		=> 'stock', 
												:host 			=> '192.168.3.20')
	end
end

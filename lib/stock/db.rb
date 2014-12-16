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
		PG::Connection.open(:user     => 'user',
												:password => 'password',
												:host     => 'server_name_or_ip', 
												:dbname   => 'schema_name')
	end
end

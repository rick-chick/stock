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
    PG::Connection.open(:user       => 'postgres',
                        :password   => 'admin',
                        :dbname     => 'stock', 
                        :host       => 'localhost')
  end
end

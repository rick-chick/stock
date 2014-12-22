class Db
  @@conn 
  def self.conn
    @@conn ||= open
    status = @@conn.connect_poll
    if status == PGconn::CONNECTION_BAD
			p "reconnect"
      @@conn.close
      @@conn = open
    else
      @@conn
    end
  end

  def self.open
    @@settings ||= YAML::load_file(File.expand_path(File.dirname(__FILE__) + "/../../db/config.yml"))
    params = @@settings["development"]
    PG::Connection.open(:user       => params["username"],
                        :password   => params["password"],
                        :dbname     => params["database"],
                        :host       => params["host"],
                       )
  end
end

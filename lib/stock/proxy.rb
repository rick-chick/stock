Capybara.configure do |conf|
  conf.run_server = false
  conf.current_driver = :poltergeist
  conf.javascript_driver = :poltergeist
  conf.app_host = 'http://www.cybersyndrome.net/'
  conf.default_wait_time = 5
end

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(
    app, {timeout:   120, 
          js_errors: false ,
         }
  )
end

class Proxy

  class << self

    include Capybara::DSL

    attr_accessor :list

    def get_list
      $stdout = Class.new do
        def self.write(a); end
        def self.flush;end
      end
      visit('/search.cgi?q=&a=ABC&f=l&s=new&n=200')
      page_source = page.body.toutf8
      $stdout = STDOUT
      @list = page_source.scan(/(\d+)\.(\d+)\.(\d+)\.(\d+):(\d+)/).map do |ip|
        "http://#{ip[0]}.#{ip[1]}.#{ip[2]}.#{ip[3]}:#{ip[4]}/"
      end
    end

  end

  def initialize
    @start = Time.now
    @proxy = Proxy.list.shuffle.first
  end
  
  def delete_bad
    if Time.now - @start > 5 
      puts "too slow proxy: #{@proxy}"
      Proxy.list.delete(@proxy)
    end
  end

  def current
    @proxy
  end

  def delete
    Proxy.list.delete(@proxy)
  end

  def options
    {:proxy => @proxy, 
     :read_timeout => 15}
  end
end

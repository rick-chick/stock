#coding: utf-8

class WebDriver
  def self.instance
    driver = Selenium::WebDriver.for :chrome
    driver.manage.window.resize_to 200, 140
    driver
  end
end

class SmbcStock

  TOP_URL = 'https://trade.smbcnikko.co.jp'
  DEFAULT_RELOAD_INTERVAL = 60 * 15

  def initialize
    @wait = Selenium::WebDriver::Wait.new(:timeout => 20)
  end

  def log_in(tentou_code, kouza_code, password)
    @driver = WebDriver.instance
    @driver.navigate.to 'https://trade.smbcnikko.co.jp/Login/0/login/ipan_web/hyoji/'
    e = @wait.until { @driver.find_element(:css , '#padInput0') }
    e.send_key(tentou_code)
    e.send_key("\t")
    e = @wait.until { @driver.find_element(:css , '#padInput1') }
    e.send_key(kouza_code)
    e.send_key("\t")
    e = @wait.until { @driver.find_element(:css , '#padInput2') }
    e.send_key(password)
    e.send_key("\t")
    @driver.find_element(:css, '.inputBtn > input:nth-child(1)').submit
    e = @wait.until { @driver.find_element(:css, 'body > div:nth-child(5) > table:nth-child(1) > tbody > tr > td:nth-child(3) > a') }
    @driver.navigate.to e.attribute('href')
    @torihiki_url = @driver.current_url
    @last_loaded = Time.now
  end

  def recept(order)
    order.status = Status::Denied.new
    if order.cancel
      cancel(order)
    elsif order.new? 
      case order
      when Order::Sell::Repay, Order::Buy::Repay
        @driver.navigate.to(TOP_URL + order.edit_url)
        edit_new_order_page(order)
      when Order::Buy
        url = @driver.find_element(:css, '#printzone > div.con_tbl_basic01 > table > tbody > tr > td > div:nth-child(5) > table > tbody > tr:nth-child(2) > td:nth-child(5) > table > tbody > tr:nth-child(2) > td > div > div:nth-child(1) > span > a').attribute('href')
        @driver.navigate.to url
        edit_new_order_page(order)
      when Order::Sell
        url = @driver.find_element(:css, '#printzone > div.con_tbl_basic01 > table > tbody > tr > td > div:nth-child(5) > table > tbody > tr:nth-child(2) > td:nth-child(5) > table > tbody > tr:nth-child(2) > td > div > div:nth-child(2) > span > a').attribute('href')
        @driver.navigate.to url
        edit_new_order_page(order)
      else
        raise UndefinedTradeTypeError
      end
    else
      raise OrderMustHaveEditUrlError if not order.edit_url
      @driver.navigate.to(TOP_URL + order.edit_url)
      edit_order_page(order)
    end
    order
  rescue => e
    puts e.message
    puts e.backtrace[0..50]
    order
  ensure
    @driver.navigate.to @torihiki_url
    @last_loaded = Time.now
  end

  def cancel(order)
    return order if not order.cancel_url
    @driver.navigate.to(TOP_URL + order.cancel_url)
    es = @driver.find_elements(:css, '#printzone form input[type="image"]' )
    e = es.find { |e| e.attribute('alt') == '注文を取り消す' }
    if not e
      @driver.navigate.to @torihiki_url
      return order
    end
    e.click
    es = @driver.find_elements(:css, '#printzone > div.con_tbl_basic02 > div span span')
    if es.length > 0 
      order.no = es[0].text.scan(/([\d]*)番/)[0][0]
      order.status = Status::Cancel.new
    end
    @driver.navigate.to @torihiki_url
    @last_loaded = Time.now
    order
  end

  def edit_order_page(order)
    raise InvalidOrderEditError if not order.edited
    es = @driver.find_elements(:css, '#printzone input[type="text"]') 
    e = es.find {|e| e.attribute('name') == 'tseiSu'}
    if e
      e.send_key(order.volume) 
      e.click
    end
    if not order.force
			es = @driver.find_elements(:css, '#printzone > div.con_tbl_basic02 > table > tbody > tr > td > form > div > table > tbody > tr:nth-child(4) > td > div > div.con_mrg03 > table > tbody > tr > td:nth-child(1) > table > tbody > tr:nth-child(9) input[type="text"]')
      if es.length == 0
				es = @driver.find_elements(:css, '#printzone > div.ml15.mr15 > form > table > tbody > tr:nth-child(4) > td > div > div.con_mrg03 > table > tbody > tr > td:nth-child(1) > div:nth-child(1) > table > tbody > tr:nth-child(9) > td > table > tbody > tr > td:nth-child(3) > input[type="text"]')
			end
      if es.length == 0
        es = @driver.find_elements(:css, '#itanka > table > tbody > tr:nth-child(1) > td > table > tbody > tr > td:nth-child(2) > div > table > tbody > tr > td:nth-child(1) > input[type="text"]')
      end
			if es.length == 0
				es = @driver.find_elements(:css, '#printzone > div.con_tbl_basic02 > table > tbody > tr > td > form > div > table > tbody > tr:nth-child(4) > td > div > div.con_mrg03 > table > tbody > tr > td:nth-child(1) > div.con_mrg04 > table > tbody > tr:nth-child(9) > td > input[type="text"]:nth-child(3)')
			end
			if es.length == 0
				es = @driver.find_elements(:css, '#printzone > div.con_tbl_basic02 > table > tbody > tr > td > form > div > table > tbody > tr:nth-child(4) > td > div > div.con_mrg03 > table > tbody > tr > td:nth-child(1) > div.con_mrg04 > table > tbody > tr:nth-child(9) > td > table > tbody > tr > td:nth-child(3) > input[type="text"]')
			end
			if es.length == 0
				es = @driver.find_elements(:css, '#printzone > div.con_tbl_basic02 > table > tbody > tr > td > form > div > table > tbody > tr:nth-child(4) > td > div > div.con_mrg03 > table > tbody > tr > td:nth-child(1) > div:nth-child(1) > table > tbody > tr:nth-child(9) > td > table > tbody > tr > td:nth-child(3) > input[type="text"]')
			end
			if es.length == 0
				es = @driver.find_elements(:css, '#printzone > div.con_tbl_basic02 > table > tbody > tr > td > form > div > table > tbody > tr:nth-child(4) > td > div > div.con_mrg03 > table > tbody > tr > td:nth-child(1) > div.con_mrg04 > table > tbody > tr:nth-child(9) > td input[type="text"]')
			end
      raise CantFindElementError if es.length == 0
      es[0].send_key order.price
      es[0].click
    else
      es = @driver.find_elements(:css, '#j')
      if es.length == 0 
				es = @driver.find_elements(:css, '#nari')
      end
      raise CantFindElementError if es.length == 0
      es[0].send_key ' '
      es[0].click
    end

    es = @driver.find_elements(:css, '#tojit')
    if es.length > 0
      es[0].send_key ' ' 
      es[0].click
    end

    es = @driver.find_elements(:css, '#printzone input[type="image"]')
    e = es.find {|e| e.attribute('alt') =~ /内容を確認する/ }
    raise CantFindElementError if not e
    e.click

    es = @driver.find_elements(:css, '#printzone input[type="image"]')
    raise CantFindElementError if es.length == 0
    e = es.find {|e| e.attribute('alt') =~ /訂正/ }
    raise CantFindElementError if not e
    e.click
     
    es = @driver.find_elements(:css, '#printzone span')
    raise CantFindElementError if es.length == 0
    es.each do |e|
      no = e.text.scan(/受付No.は([\d]*)番/)
      next if no.length == 0
      order.no = no[-1][0]
      order.status = Status::Edited.new
    end
    raise CantFindElementError if not order.status.kind_of? Status::Edited
  end

  def edit_new_order_page(order)
    es = @driver.find_elements(:css, '#imeig > table > tbody > tr > td:nth-child(1) > input[type="text"]:nth-child(2)')
    if es.length > 0 
      @driver.action.send_keys(:tab).perform while not es[0].displayed? 
      es[0].location_once_scrolled_into_view
      es[0].send_key order.code
    end

    if order.force
      @driver.find_element(:css, '#j').send_key ' '
    else
      @driver.find_element(:css, '#itanka > table > tbody > tr:nth-child(1) > td > table > tbody > tr > td:nth-child(2) > div > table > tbody > tr > td:nth-child(1) > input[type="text"]'
                          ).send_key order.price
    end
    es = @driver.find_elements(:css, '#isuryo > table > tbody > tr:nth-child(1) > td:nth-child(1) > input[type="text"]')
    if es.length > 0
      es[0].send_key order.volume
      es[0].click
    end
    es = @driver.find_elements(:css, '#seido')
    if es.length > 0 
       es[0].send_key ' '
       es[0].click
    end
    es = @driver.find_elements(:css, '#tojit')
    if es.length > 0
      es[0].send_key ' ' 
      es[0].click 
    end

    e = @driver.find_elements(:css, '#printzone form input[type="image"]').find do |e| 
      e.attribute('name') == 'execUrl' or e.attribute('name') == 'autotukeUrl'
    end 
    raise CantFindElementError if not e
    e.click
    e = @driver.find_elements(:css, '#printzone input[type="image"]').find do |e| 
      e.attribute('alt') == '注文する'
    end
    raise CantFindElementError if not e
    e.click

    es = @driver.find_elements(:css, '#printzone > form > div > table > tbody > tr > td > div:nth-child(2)')
    raise CantFindElementError if es.length == 0
    order.no = es[0].text.scan(/([\d]*)番/)[0][0]
    order.status = Status::Orderd.new if order.no != "" 
  end

  def hands
    e = @wait.until { @driver.find_element(:css, '#printzone > div.con_tbl_basic01 > table > tbody > tr > td > div:nth-child(5) > table > tbody > tr:nth-child(2) > td:nth-child(5) > table > tbody > tr:nth-child(2) > td > div > div:nth-child(3) > span > a') }
    @driver.navigate.to e.attribute('href')
    page = Nokogiri::HTML.parse(@driver.page_source)
    result = []
    trs = page.css('#printzone > div.con_tbl_basic02 > table > tbody > tr > td > table > tbody > tr:nth-child(1) > td > div > form > div:nth-child(3) > table:nth-child(2) > tbody > tr')
    return result if not trs.length > 1
    hash = {}
    trs[1..-1].each do |tr|
      tds = tr.css('td')
      txts = tds.map {|td| td.text.gsub(/\\u([\da-fA-F]{4})/) { $1.hex.chr('utf-8') }}
      index = 0
      scans = txts[index].scan(/(\d+)\//)
      if scans[0] and scans[0][0]
        hash[:code] = scans[0][0]
        index += 1
      end
      if txts[index] =~ /買/
        hash[:trade_kbn] = :buy
        index += 1
      elsif txts[index] =~ /売/
        hash[:trade_kbn] = :sell
        index += 1
      end
      if txts[index] =~ /特定/
        hash[:kouza_kbn] = :tokutei
        index += 1
      end
      hash[:volume] = txts[index].gsub(',','').scan(/\d+/)[0].to_i
      index += 1
      scans = tds[index].to_s.gsub(',','').scan(/(\d+)<br>(\d+)/)
      hash[:order_price] = scans[0][0].to_f
      hash[:price] = scans[0][1].to_f
      index += 1
      scans = txts[index].gsub(',','').scan(/[\d-]+/)
      hash[:profit] = scans[0].to_i
      index += 1
      hash[:asset] = txts[index].gsub(',','').scan(/\d+/)[0].to_i
      index += 1
      if txts[index]
        hash[:date]  = txts[index].gsub('/','').scan(/\d+/)[0]
        index += 1
      end
      if txts[index] =~ /制度/
        hash[:kigen] = :seido
        index += 1
      elsif txts[index+1] =~ /制度/
        hash[:kigen] = :seido
        index += 2
      elsif txts[index] =~ /一般/
        hash[:kigen] = :ippan
        index += 1
      elsif txts[index+1] =~ /一般/
        hash[:kigen] = :ippan
        index += 2
      end
      if txts[index] =~ /返済/
        hash[:url] = tds[index].css('a').attribute('href').value
      end
      result << Hand.new(hash)
    end
    result
  rescue => e
    raise(StandardError,e.message+'!!',e.backtrace)
  ensure
    @driver.navigate.to @torihiki_url
    @last_loaded = Time.now
  end

  def orders
    e = @wait.until { @driver.find_element(:css, '#printzone > div.con_tbl_basic01 > table > tbody > tr > td > div:nth-child(5) > table > tbody > tr:nth-child(2) > td:nth-child(5) > table > tbody > tr:nth-child(2) > td > div > div:nth-child(4) > span > a') }
    @driver.navigate.to e.attribute('href')
    page = Nokogiri::HTML.parse(@driver.page_source)
    result = []
    trs = page.css('#printzone table tbody tr td table:nth-child(7) tbody tr')
			#'#printzone > div:nth-child(3) > table > tbody > tr > td > table:nth-child(7) > tbody > tr')
    return result if not trs.length > 1
    trs[1..-1].each do |tr|
      tds = tr.css('td')
      txts = tds.map {|td| td.text.gsub(/\\u([\da-fA-F]{4})/) { $1.hex.chr('utf-8') }}
      hash = {}
      hash[:code] = txts[0].scan(/\d{4}/)[0]
      hash[:force] = (txts[3] =~ /成行/)
      hash[:volume] = txts[3].split("\t")[1].scan(/\d/).join('')
      hash[:price] = txts[3].split("\t")[2].scan(/\d/).join('')
      hash[:contracted_volume] = txts[4].split("\t")[1].scan(/\d/).join('')
      hash[:contracted_price] = txts[4].split("\t")[2].scan(/\d/).join('')
      hash[:status] = Status.create(txts[6])
      hash[:no] = txts[7].scan(/\d/).join('')
      as = tds[8].css('a')
      if as.length > 0 
        hash[:cancel_url] = as[0].attribute('href').value 
        hash[:edit_url] = as[1].attribute('href').value if as.length > 1
      end
      hash[:date] = txts[9].split("\t")[1].scan(/\d/).join('')
      order = Order.create(hash, txts[1] =~ /買/, txts[2] =~ /返済/)
      result << order
    end
    result
  rescue => e
    raise(StandardError,e.message+'!!',e.backtrace)
  ensure
    @driver.navigate.to @torihiki_url
    @last_loaded = Time.now
  end

  def unloaded_over_interval?
    Time.now - @last_loaded > DEFAULT_RELOAD_INTERVAL
  end

  def reload
    @driver.navigate.to @torihiki_url
    @last_loaded = Time.now
  end

  class UndefinedTradeTypeError < StandardError; end
  class UndefinedStatusError < StandardError; end
  class InvalidOrderError < StandardError; end
  class InvalidOrderEditError < StandardError; end
  class CantFindElementError < StandardError; end
  class OrderMustHaveEditUrlError < StandardError; end
end

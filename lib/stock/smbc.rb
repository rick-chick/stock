#coding: utf-8
require 'selenium-webdriver'
require 'open-uri'
require 'nokogiri'
require File.dirname(File.expand_path(__FILE__)) + '/order'
require File.dirname(File.expand_path(__FILE__)) + '/status'
require File.dirname(File.expand_path(__FILE__)) + '/player'
require File.dirname(File.expand_path(__FILE__)) + '/board'

class WebDriver
  def self.instance
    driver = Selenium::WebDriver.for :chrome
    driver.manage.window.resize_to 200, 140
    driver
  end
end

class SmbcStock

  TOP_URL = 'https://trade.smbcnikko.co.jp'

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
  end

  def recept(order)
    if order.new? 
      case order
      when Order::Buy
        url = @driver.find_element(:css, '#printzone > div.con_tbl_basic01 > table > tbody > tr > td > div:nth-child(5) > table > tbody > tr:nth-child(2) > td:nth-child(5) > table > tbody > tr:nth-child(2) > td > div > div:nth-child(1) > span > a').attribute('href')
        @driver.navigate.to url
        edit_new_order_page(order)
      when Order::Sell
        url = @driver.find_element(:css, '#printzone > div.con_tbl_basic01 > table > tbody > tr > td > div:nth-child(5) > table > tbody > tr:nth-child(2) > td:nth-child(5) > table > tbody > tr:nth-child(2) > td > div > div:nth-child(2) > span > a').attribute('href')
        @driver.navigate.to url
        edit_new_order_page(order)
      when Order::RepayBuy, Order::RepaySell
      else
        throw UndefinedTradeTypeError
      end
    else
      @driver.navigate.to(TOP_URL + order.edit_url)
      edit_order_page(order)
    end
    @driver.navigate.to @torihiki_url
    order
  end

  def cancel(order)
    return order if not order.cancel_url
    @driver.navigate.to(TOP_URL + order.cancel_url)
    e = @wait.until { @driver.find_element(:css, '#printzone > div.ml15.mr15 > table > tbody > tr:nth-child(4) > td > div > div.mt15 > table > tbody > tr > td > table > tbody > tr:nth-child(1) > td > form > input[type="image"]:nth-child(17)') }
    e.send_key ' '
    order.status = Status::Cancel.new
    @driver.navigate.to @torihiki_url
    es = @wait.until { @driver.find_elements(:css, '#printzone > div.con_tbl_basic02 > div:nth-child(4) > span') }
    if es.length > 0 
      es[0].send_key ' '
      e = @wait.until {@driver.find_element(:css, '#printzone > div.ml15.mr15 > div:nth-child(3)')}
      order.id = e.text.scan(/([\d]*)番/)[0][0]
      order.status = Status::Edited.new
    else
      order.status = Status::Denied.new
    end
    order
  end

  def edit_order_page(order)
    raise InvalidOrderEditError if order.edit_volume and order.edit_price
    if order.edit_volume
      e = @wait.until { @driver.find_element(:css, '#printzone > div.con_tbl_basic02 > table > tbody > tr > td > form > div > table > tbody > tr:nth-child(4) > td > div > div.con_mrg03 > table > tbody > tr > td:nth-child(1) > div.con_mrg04 > table > tbody > tr:nth-child(7) > td > table > tbody > tr > td:nth-child(1) > input[type="text"]') }
      @driver.action.send_keys(:tab).peform while not e.displayed?
      e.send_key order.volume
    end
    if order.edit_price
      if not order.force
        e = @wait.until { @driver.find_element(:css, '#printzone > div.con_tbl_basic02 > table > tbody > tr > td > form > div > table > tbody > tr:nth-child(4) > td > div > div.con_mrg03 > table > tbody > tr > td:nth-child(1) > div.con_mrg04 > table > tbody > tr:nth-child(9) > td > table > tbody > tr > td:nth-child(3) > input[type="text"]') }
        @driver.action.send_keys(:tab).perform while not e.displayed?
        e.send_key order.price
      else
        e = @wait.until { @driver.find_element(:css, '#nari') }
        @driver.action.send_keys(:tab).perform while not e.displayed?
        e.send_key ' '
      end
    end
    @driver.action.send_keys(:return).perform
    es = @wait.until { @driver.find_elements(:css, '#printzone > div.ml15.mr15 > div.con_mrg06 > table > tbody > tr:nth-child(4) > td > div > div.mt10 > table > tbody > tr > td > table > tbody > tr:nth-child(1) > td > div:nth-child(1) > form > input[type="image"]:nth-child(16)') }
    if es.length > 0 
      es[0].send_key ' '
      e = @wait.until {@driver.find_element(:css, '#printzone > div.ml15.mr15 > div:nth-child(3)')}
      order.id = e.text.scan(/([\d]*)番/)[0][0]
      order.status = Status::Edited.new
    else
      order.status = Status::Denied.new
    end
    order
  end

  def edit_new_order_page(order)
    e = @wait.until { @driver.find_element(:css, '#imeig > table > tbody > tr > td:nth-child(1) > input[type="text"]:nth-child(2)') }
    @driver.action.send_keys(:tab).perform while not e.displayed? 
    e.location_once_scrolled_into_view
    e.send_key order.code
    if order.force
      @driver.find_element(:css, '#j').send_key ' '
    else
      @driver.find_element(:css, '#itanka > table > tbody > tr:nth-child(1) > td > table > tbody > tr > td:nth-child(2) > div > table > tbody > tr > td:nth-child(1) > input[type="text"]'
                          ).send_key order.price
    end
    es = @driver.find_elements(:css, '#isuryo > table > tbody > tr:nth-child(1) > td:nth-child(1) > input[type="text"]')
    es[0].send_key order.volume if es.length > 0
    es = @driver.find_elements(:css, '#seido')
    es[0].send_key ' ' if es.length > 0 
    es = @driver.find_elements(:css, '#tojit')
    es[0].send_key ' ' if es.length > 0
    @driver.find_elements(:css, 'input').find {|e| e.attribute('name') == 'execUrl' }.send_key ' '
    e = @wait.until { @driver.find_element(:css, '#printzone > div.con_tbl_basic02 > table > tbody > tr > td > div.con_mrg02 > table > tbody > tr:nth-child(4) > td > div > div:nth-child(2) > table > tbody > tr:nth-child(2) > td > div.con_mrg04 > table > tbody > tr > td > table > tbody > tr:nth-child(1) > td > form > div > input[type="image"]') }
    e.send_key ' '
    es = @wait.until {@driver.find_elements(:css, '#printzone > form > div > table > tbody > tr > td > div:nth-child(2)')}
    if es.length > 0 
      order.id = es[0].text.scan(/([\d]*)番/)[0][0]
      order.status = Status::Orderd.new
    else
      order.status = Status::Denied.new
    end
  end

  def hands
    e = @wait.until { @driver.find_element(:css, '#printzone > div.con_tbl_basic01 > table > tbody > tr > td > div:nth-child(5) > table > tbody > tr:nth-child(2) > td:nth-child(5) > table > tbody > tr:nth-child(2) > td > div > div:nth-child(3) > span > a') }
    @driver.navigate.to e.attribute('href')
    page = Nokogiri::HTML.parse(@driver.page_source)
    result = []
    trs = page.css('#printzone > div:nth-child(3) > table > tbody > tr > td > table:nth-child(7) > tbody > tr')
    return result if not trs.length > 1
    trs[1..-1].each do |tr|
      tds = tr.css('td')
      txts = tds.map {|td| td.text.gsub(/\\u([\da-fA-F]{4})/) { $1.hex.chr('utf-8') }}
      hash = {}
    end
  end

  def orders
    e = @wait.until { @driver.find_element(:css, '#printzone > div.con_tbl_basic01 > table > tbody > tr > td > div:nth-child(5) > table > tbody > tr:nth-child(2) > td:nth-child(5) > table > tbody > tr:nth-child(2) > td > div > div:nth-child(4) > span > a') }
    @driver.navigate.to e.attribute('href')
    page = Nokogiri::HTML.parse(@driver.page_source)
    result = []
    trs = page.css('#printzone > div:nth-child(3) > table > tbody > tr > td > table:nth-child(7) > tbody > tr')
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
      hash[:id] = txts[7].scan(/\d/).join('')
      as = tds[8].css('a')
      if as.length > 0 
        hash[:cancel_url] = as[0].attribute('href').value 
        hash[:edit_url] = as[1].attribute('href').value if as.length > 1
      end
      hash[:date] = txts[9].split("\t")[1].scan(/\d/).join('')
      order = Order.create(hash, txts[1] =~ /買/, txts[2] =~ /返済/)
      result << order
    end
    @driver.navigate.to @torihiki_url
    result
  end

  class UndefinedTradeTypeError < StandardError; end
  class UndefinedStatusError < StandardError; end
  class InvalidOrderError < StandardError; end
  class InvalidOrderEditError < StandardError; end
end

agent = SmbcStock.new
agent.log_in(ARGV[0].strip, ARGV[1].strip, ARGV[2].strip)
agent.recept Order::Sell.new(code: 1579, volume: 10, force: true)
agent.recept Order::Buy.new(code: 1579, volume: 10, force: true)

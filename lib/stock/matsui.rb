#coding: utf-8
require 'selenium-webdriver'
require 'objspace'
require 'open-uri'

class WebDriver
  def self.instance
    driver = Selenium::WebDriver.for :chrome
    driver.manage.window.resize_to 200, 200
    driver
  end
end

class MatsuiStock

  attr_accessor :pin_code

  def log_in(user_name, password)
    @driver = WebDriver.instance
    @driver.navigate.to 'https://www.deal.matsui.co.jp/ITS/login/MemberLogin.jsp'
    e = @driver.find_element(:name , 'clientCD')
    e.location_once_scrolled_into_view
    @driver.action.send_keys :tab while not e.displayed?
    e.send_key(user_name)
    e = @driver.find_element(:name , 'passwd')
    @driver.action.send_keys :tab while not e.displayed?
    e.send_key(password)
    @driver.find_element(:id, 'btn_opn_login').submit
    @driver.switch_to.frame(0)
    sleep 1
    @driver.navigate.to @driver.find_elements(:tag_name, 'a')[1].attribute('href')
    @driver.navigate.to @driver.find_elements(:tag_name, 'frame')[1].attribute('src')
  end

  def buy(code, price, volume)
    order(code, price, volume, 'tradeKbn_13')
  end

  def sell(code, price, volume)
    order(code, price, volume, 'tradeKbn_111')
  end

  def order(code, price, volume, radio_name)
    open_order(code) do 
      form = @driver.find_element(:tag_name, 'form')
      form.find_element(:name ,'orderNominal').send_key(volume)
      form.find_element(:name ,'orderPrc').send_key(price)
      form.find_element(:id , radio_name).click
      form.find_element(:name, 'tyukakuButton').click
      @driver.find_element(:name, 'pinNo').send_key(@pin_code)
      @driver.find_elements(:tag_name, 'input')[1].click
    end
  end

  def watch(code)
    open_order(code) do
      values = []
      doc = Nokogiri::HTML(@driver.page_source)
      doc.xpath(".//table[1]").first
      .xpath(".//table[2]")[3]
      .xpath(".//tr/td[2]").each do |element|
        values << element.text.trim_unit
      end
      status = {}
      status[:price] = values[1].gsub(/[^0-9].*/,'').to_i
      status[:volume] = values[2].to_i
      status[:sel_price] = values[3].split('-')[0].to_i
      status[:sel_volume] = values[3].split('-')[1].to_i
      status[:buy_price] = values[4].split('-')[0].to_i
      status[:buy_volume] = values[4].split('-')[1].to_i
      status[:open] = values[5].to_i
      status[:high] = values[6].to_i
      status[:low] = values[7].to_i
      status[:unit] = values[8].to_i
      return status 
    end
  end

  def open_order(code)
    begin
      @driver.switch_to.window @driver.window_handles[0]
      element = @driver.find_elements(:tag_name, 'input')[0]
      element.clear
      element.send_key(code)
      element.submit
      @driver.switch_to.window @driver.window_handles[1]
      sleep 1
      yield
    rescue => ex
      puts ex.message
      puts ex.backtrace
    ensure
    end
  end

  def open_hands
    ret = {}
    begin
      @driver.switch_to.window @driver.window_handles[0]
      element = @driver.find_elements(:tag_name, 'a')[2]
      element.click
      src = @driver.find_elements(:tag_name, 'frame')[-1].attribute('src')
      @driver.navigate.back
      open(src) do |page|
        doc = Nokogiri.parse(page.read)
        doc.css('form table')[8].css('tr')[1..-1].each do |tr|
          td     = tr.css('td')
          code   = td[2].text.scan(/\[.+\](\d+)/)[0][0]
          volume = td[3].text.gsub(/[^\d]/, '')
          price  = td[4].text.gsub(/[^\d]/, '')
          ret[code] = {}
          ret[code][:volume] = volume
          ret[code][:price]  = price
        end
      end
    rescue => ex
      puts ex.message
      puts ex.backtrace
    ensure
      sleep 1
    end
    ret
  end

  def orders
    ret = {}
    begin
      @driver.switch_to.window @driver.window_handles[0]
      element = @driver.find_elements(:tag_name, 'a')[0]
      element.click
      src = @driver.find_elements(:tag_name, 'frame')[-1].attribute('src')
      @driver.navigate.back
      open(src) do |page|
        doc = Nokogiri.parse(page.read)
        doc.css('form table')[8].css('tr')[1..-1].each do |tr|
          td     = tr.css('td')
          code   = td[2].text.scan(/\[.+\](\d+)/)[0][0]
          trade  = td[4].text
          volume = td[5].text.gsub(/[^\d]/,'')
          if td[6].text.include? '成行'
            price  = 0
          else
            price  = td[6].text.gsub(/[^\d]/,'')
          end
          date   = Time.now.strftime('%Y') + td[7].text.scan(/\d{2}\/\d{2}/)[0].sub('/','')
          time   = td[7].text.scan(/\d{2}:\d{2}/)[0]
          ret[code] ||= []
          ret[code] << hash = {}
          hash[:trade]  = trade
          hash[:volume] = volume
          hash[:price] = price
          hash[:date] = date
          hash[:time] = time
        end
      end
    rescue => ex
      puts ex.message
      puts ex.backtrace
    ensure
      sleep 1
    end
    ret
  end

  def exit
    true
  end

  def continue
    false
  end

  class StockBoard < MatsuiStock

    def open
      e = @driver.find_element(:css, 'body > table > tbody > tr:nth-child(1) > td > table > tbody > tr:nth-child(22) > td:nth-child(2) > a')
      @driver.navigate.to e.attribute('href')
      e = @driver.find_element(:css, '#Control > input[type="button"]:nth-child(1)')
      e.send_key :enter
    end

    def set(codes)
      @codes = codes
      wait_load
      es = @driver.find_elements(:css, '#design-fourRatesList > div.wrap-portfolio div.group-stock')
      codes.each_with_index do |code, index|
        input = es[index].find_element(:css, 'input.q-code')
        input.send_key ''
        input.send_key code
      end
			@driver.action.send_keys :tab
			@driver.action.send_keys :tab
    end

    def watch(&block)
      raise 'first you must open_board and set_board' if not @codes
      start = Time.now
      begin
        if Time.now - start > 900
					@driver.navigate.refresh
					set(@codes)
          start = Time.now
        end
        wait_load
			rescue => ex
        puts ex.message
        puts ex.backtrace
      end while block.call(read)
    end

    def wait_load
      sleep 1 while @driver.find_elements(:css, '#design-fourRatesList > div.wrap-portfolio div.group-stock').length == 1
    end

    def read
      result = []
      page = Nokogiri::HTML @driver.page_source
      objs = ObjectSpace.each_object.inject(Hash.new 0) {|h,o| h[o.class]+=1; h }
      if @objs
        objs.each do |c,i|
          @objs[c] ||= i
          if @objs[c] < i
            puts "#{c} #{i}" 
            @objs[c] = i
          end
        end
      end

      lines = page.css('#design-fourRatesList > div.wrap-portfolio div.group-stock')
      @codes.each_with_index do |code, index|
        hash = {}
        line = lines[index]
        hash[:code] = code
        divs = line.css('td.td02 div')
        hash[:price] = divs[0].text.scan(/[.\d]+/)[0].to_f
        scans = divs[1].text.scan(/([^\d]*)([\d:]+)/)[0]
        next if not scans
        hash[:closed] = scans[0] != ""
        hash[:time] = scans[1]
        divs = line.css('td.td03 div')
        hash[:diff] = divs[0].text.scan(/[-.\d]+/)[0].to_f
        hash[:rate] = divs[1].text.scan(/[-.\d]+/)[0].to_f
        divs = line.css('td.td04 div')
        hash[:open] = divs[0].text.scan(/[.\d]+/)[0].to_f
        hash[:open_time] = divs[1].text.scan(/[:\d]+/)[0]
        divs = line.css('td.td05 div')
        hash[:high] = divs[0].text.scan(/[.\d]+/)[0].to_f
        hash[:high_time] = divs[1].text.scan(/[:\d]+/)[0]
        divs = line.css('td.td06 div')
        hash[:low] = divs[0].text.scan(/[.\d]+/)[0].to_f
        hash[:low_time] = divs[1].text.scan(/[:\d]+/)[0]
        divs = line.css('td.td07 div')
        hash[:sell] = divs[0].text.scan(/[.\d]+/)[0].to_f
        hash[:sell_volume] = divs[1].text.scan(/[.\d]+/)[0].to_f
        hash[:toku] = divs[0].text.include?('特')
        divs = line.css('td.td08 div')
        hash[:buy] = divs[0].text.scan(/[.\d]+/)[0].to_f
        hash[:buy_volume] = divs[1].text.scan(/[.\d]+/)[0].to_f
        hash[:toku] = hash[:toku] or divs[0].text.include?('特')
        divs = line.css('td.td09 div')
        hash[:volume] = divs[0].text.scan(/[.\d]+/)[0].to_f
        hash[:tick] = divs[1].text.scan(/[.\d]+/)[0].to_f
        result << Board.new(hash)
      end
      result
		rescue => ex
      puts ex.message
      puts ex.backtrace
			[]
    end

  end
end

class String
  def trim_unit
    sub(',', '').sub('株', '').sub('円', '')
  end
end

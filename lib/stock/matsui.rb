#coding: utf-8
require 'selenium-webdriver'
require 'open-uri'

class WebDriver
  def self.instance
    driver = Selenium::WebDriver.for :chrome
    driver.manage.window.resize_to 200, 100
    driver
  end
end

class MatsuiStock

  attr_accessor :pin_code

  def log_in(user_name, password)
    @driver = WebDriver.instance
    @driver.navigate.to 'https://www.deal.matsui.co.jp/ITS/login/MemberLogin.jsp'
    @driver.find_element(:name , 'clientCD').send_key(user_name)
    @driver.find_element(:name , 'passwd').send_key(password)
    @driver.find_element(:id, 'btn_opn_login').submit
    @driver.switch_to.frame(0)
    sleep 1
    @driver.navigate.to @driver.find_elements(:tag_name, 'a')[1].attribute('href')
    @driver.navigate.to @driver.find_elements(:tag_name, 'frame')[1]
    .attribute('src')
  end

  def buy(code, price, volume)
    order(code, price, volume, 'tradeKbn')
  end

  def sell(code, price, volume)
    order(code, price, volume, 'tradeKbn')
  end

  def order(code, price, volume, radio_name)
    open_order(code) do 
      form = @driver.find_element(:tag_name, 'form')
      form.find_element(:name ,'orderNominal').send_key(volume)
      form.find_element(:name ,'orderPrc').send_key(price)
      form.find_element(:name , radio_name).click
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

  def exit
    true
  end

  def continue
    false
  end

end

class String
  def trim_unit
    sub(',', '').sub('株', '').sub('円', '')
  end
end

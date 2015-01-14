LIB_DIR = File.expand_path(File.dirname(__FILE__))
require 'optparse'
require 'pg'
require 'nokogiri'
require 'open-uri'
require 'date'
require 'standalone_migrations'
require 'parallel'
require 'kconv'
require 'rack'
require 'capybara'
require 'capybara/dsl'
require 'capybara/poltergeist'
require 'phantomjs'
require LIB_DIR + '/stock/db'
require LIB_DIR + '/stock/stocks'
require LIB_DIR + '/stock/stock'
require LIB_DIR + '/stock/split'
require LIB_DIR + '/stock/code'
require LIB_DIR + '/stock/date'
require LIB_DIR + '/stock/proxy'
require LIB_DIR + '/stock/yahoo'
require LIB_DIR + '/stock/k_db'
require LIB_DIR + '/stock/code_date'
require LIB_DIR + '/stock/code_time'
require LIB_DIR + '/stock/fx'
require LIB_DIR + '/cluster/k-means'
require LIB_DIR + '/cluster/cluster'
require LIB_DIR + '/cluster/node'
require LIB_DIR + '/bayesian/node'
require LIB_DIR + '/bayesian/k2metric'

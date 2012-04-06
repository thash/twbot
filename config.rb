# -*- coding: utf-8 -*-
require "rubygems"
require "bundler/setup"
require 'net/http'
require 'nokogiri'
require 'hashie'
require 'pry'
require 'yaml'
require 'logger'
require 'mongoid'

### config ---------------------------------
$settings  = Hashie::Mash.new(YAML.load_file('./settings.yml'))
$secret    = Hashie::Mash.new(YAML.load_file('./secret.yml'))

Mongoid.configure do |config|
    config.master = Mongo::Connection.new($settings.mongoid.host, $settings.mongoid.port).db($settings.mongoid.db)
end

$logger    = Logger.new('log/hatetw.log')
$botlogger = Logger.new('log/bot.log')

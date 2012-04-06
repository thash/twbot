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
@yml = Hashie::Mash.new(YAML.load_file('./mongoid.yml'))
Mongoid.configure do |config|
    config.master = Mongo::Connection.new(@yml.host, @yml.port).db(@yml.db)
end

$logger    = Logger.new('log/hatetw.log')
$botlogger = Logger.new('log/bot.log')
$settings  = Hashie::Mash.new(YAML.load_file('./settings.yml'))
$secret    = Hashie::Mash.new(YAML.load_file('./secret.yml'))


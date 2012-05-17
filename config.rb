# -*- coding: utf-8 -*-
require "rubygems"
require "bundler/setup"
Bundler.require # require all the bundled libs at once.

### config ---------------------------------
$settings  = Hashie::Mash.new(YAML.load_file('./settings.yml'))
$secret    = Hashie::Mash.new(YAML.load_file('./secret.yml'))

Mongoid.configure do |config|
  if ENV["HATETW_ENV"] == "test"
    config.master = Mongo::Connection.new($settings.mongoid_test.host, $settings.mongoid_test.port).db($settings.mongoid_test.db)
  else
    config.master = Mongo::Connection.new($settings.mongoid.host, $settings.mongoid.port).db($settings.mongoid.db)
  end
end

$logger    = Logger.new('log/hatetw.log')
$botlogger = Logger.new('log/bot.log')

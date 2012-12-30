# -*- coding: utf-8 -*-
require "rubygems"
require "bundler/setup"
Bundler.require # require all the bundled libs at once.

### config ---------------------------------
app_environment = ENV['APP_ENV'] || "development"
secret_path = case app_environment
              when "production"
                File.expand_path('../../shared/secret.yml')
              else
                './secret.yml'
              end
$secret    = Hashie::Mash.new(YAML.load_file(secret_path))
$settings  = Hashie::Mash.new(YAML.load_file('./settings.yml'))

Mongoid.configure do |config|
  if ENV["HATETW_ENV"] == "test"
    config.master = Mongo::Connection.new($settings.mongoid_test.host, $settings.mongoid_test.port).db($settings.mongoid_test.db)
  else
    config.master = Mongo::Connection.new($settings.mongoid.host, $settings.mongoid.port).db($settings.mongoid.db)
  end
end

$logger    = Logger.new('log/hatetw.log')
$botlogger = Logger.new('log/bot.log')

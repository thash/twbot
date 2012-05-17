# -*- coding: utf-8 -*-

ENV["HATETW_ENV"] ||= "test"
require File.expand_path("../../config.rb", __FILE__)
Dir[File.join(File.dirname(__FILE__), "..", "app", "**/*.rb")].each{|f| require f }

RSpec.configure do |conf|
  DatabaseCleaner.logger = Logger.new(STDOUT)
  DatabaseCleaner.logger.level = Logger::DEBUG
  conf.before(:suite) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean_with(:truncation)
    DatabaseCleaner.logger.info "[DBCleaner] set strategy to :truncation."
  end

  conf.before(:each) do
    DatabaseCleaner.start
    DatabaseCleaner.logger.info "[DBCleaner] start."
  end

  conf.after(:each) do
    DatabaseCleaner.clean
    DatabaseCleaner.logger.info "[DBCleaner] clean database."
  end
end

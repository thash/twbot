# -*- encoding: UTF-8 -*-
require "rubygems"
require "bundler/setup"
require 'yaml'
require 'twitter'

y = YAML.load_file('secret.yml')

Twitter.configure do |c|
  c.consumer_key =       y["CONSUMER_KEY"]
  c.consumer_secret =    y["CONSUMER_SECRET"]
  c.oauth_token =        y["OAUTH_TOKEN"]
  c.oauth_token_secret = y["OAUTH_TOKEN_SECRET"]
end

Twitter.update(open('source.txt').readlines.shuffle.first)

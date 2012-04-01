# -*- coding: UTF-8 -*-

require "rubygems"
require "bundler/setup"
require 'yaml'
require 'twitter'

require './hatena.rb'

@botlogger = Logger.new('bot.log')

SETTINGS = YAML.load_file('settings.yml')
y = YAML.load_file('secret.yml')

Twitter.configure do |c|
  c.consumer_key =       y["CONSUMER_KEY"]
  c.consumer_secret =    y["CONSUMER_SECRET"]
  c.oauth_token =        y["OAUTH_TOKEN"]
  c.oauth_token_secret = y["OAUTH_TOKEN_SECRET"]
end


def get_first(num)
  b = Bookmark.where(closed: false, :remind_cnt.lte => num).order_by(:time, 'asc').first if b.blank?
  return b.present? ? b : nil
end

def make_tweet(b, user="T_Hash")
  txt = ""
  txt += "@#{user} "
  txt += b.time.to_date.to_s
  txt += " に"
  txt += b.tags.map(&:text).join(",")
  txt += "タグでブクマされた "
  txt += "『" + truncate(b.title, 30) + "』 "
  txt += b.link
  txt += random_gobi
end

def random_gobi
  SETTINGS["mention_gobis"].sample(1).first
end

def truncate(txt, limit=30)
  if txt.length <= limit
    txt
  else
    txt[0..30] + "..."
  end
end

def update
  begin
    b = get_first(0)
    txt = make_tweet(b)
    Twitter.update(txt)
    b.inc(:remind_cnt, 1)
    b.save
  rescue => e
    @botlogger.error "[#{Time.now.to_s(:db)}] Twitter bot update failed."
    @botlogger.error e.message
    @botlogger.error e.backtrace.join("\n")
  end
end

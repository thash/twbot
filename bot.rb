# -*- coding: UTF-8 -*-

require "rubygems"
require "bundler/setup"
require 'yaml'
require 'httpclient'
require 'hashie'
require 'twitter'

require './hatena.rb'

@botlogger = Logger.new('logbot.log')

SETTINGS = YAML.load_file('settings.yml')
y = YAML.load_file('secret.yml')
@secret = Hashie::Mash.new(y)

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
  txt += shorten(b.link)
  txt += " "
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
  b = get_first(0)
  begin
    txt = make_tweet(b)
    status = Twitter.update(txt)
  rescue => e
    @botlogger.error "[#{Time.now.to_s(:db)}] Twitter bot update failed."
    @botlogger.error e.message
    @botlogger.error e.backtrace.join("\n")
  end
  begin
    save_post(status)
    b.inc(:remind_cnt, 1)
    b.save
  rescue => e
    @botlogger.error "[#{Time.now.to_s(:db)}] Error occurred while saving information."
    @botlogger.error e.message
    @botlogger.error e.backtrace.join("\n")
  end
end

def save_post(status)
  BotPost.create({
    status_id: status.id,
    to_user: status.in_reply_to_user_id,
    in_reply_to: status.in_reply_to_status_id,
    text: status.text,
    posted_at: status.created_at})
end

# shorten returns short url.
# full result looks something like this. {{{
# => {"status_code"=>200,
#  "status_txt"=>"OK",
#  "data"=>
#   {"long_url"=>
#     "http://m.igrs.jp/blog/2012/03/12/why-rubyists-should-try-elixir/",
#    "url"=>"http://bit.ly/I1R2ev",
#    "hash"=>"I1R2ev",
#    "global_hash"=>"yLG6Hd",
#    "new_hash"=>1}}
# }}}
def shorten(url)
  return nil if url.blank?
  hc = HTTPClient.new
  fullurl = "http://api.bitly.com/v3/shorten?longUrl=#{url}&login=#{@secret.bitly.login}&apikey=#{@secret.bitly.apikey}"
  res = Hashie::Mash.new(JSON.parse(hc.get_content(fullurl)))
  res.data.url
end

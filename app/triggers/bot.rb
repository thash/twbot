# -*- coding: UTF-8 -*-
require File.expand_path('../../../config', __FILE__)
Dir::foreach(File.expand_path('../../models/', __FILE__)) { |f|
  next if f == "." || f == ".."
  require  File.expand_path("../../models/#{f}", __FILE__)
}
require 'httpclient'
require 'twitter'

Twitter.configure do |c|
  c.consumer_key =       $secret["CONSUMER_KEY"]
  c.consumer_secret =    $secret["CONSUMER_SECRET"]
  c.oauth_token =        $secret["OAUTH_TOKEN"]
  c.oauth_token_secret = $secret["OAUTH_TOKEN_SECRET"]
end

def update
  b = Bookmark.get_first(0)
  txt = b.make_tweet(user: "T_Hash", short_level: 0)
  status = Twitter.update(txt)
  b.inc(:remind_cnt, 1)
  BotPost.store(status)
rescue Twitter::Error::Forbidden => e
  $botlogger.error  "[#{Time.now.to_s(:db)}] Long tweet! length: #{txt.length}."
  $botlogger.error  "[#{Time.now.to_s(:db)}] try to shorten tweet: #{txt}"
  txt = b.make_tweet(user: "T_Hash", short_level: 1)
  begin
    status = Twitter.update(txt)
    b.inc(:remind_cnt, 1)
    BotPost.store(status)
  rescue Twitter::Error::Forbidden => e
    $botlogger.error  "[#{Time.now.to_s(:db)}] Long tweet! length: #{txt.length}."
    $botlogger.error  "[#{Time.now.to_s(:db)}] try to shorten tweet: #{txt}"
    Twitter.update(error_mention(e))
  end
rescue => e
  $botlogger.error "[#{Time.now.to_s(:db)}] Twitter bot update failed."
  $botlogger.error e.message
  $botlogger.error e.backtrace.join("\n")
  Twitter.update(error_mention(e))
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
  fullurl = "http://api.bitly.com/v3/shorten?longUrl=#{url}&login=#{$secret.bitly.login}&apikey=#{$secret.bitly.apikey}"
  res = Hashie::Mash.new(JSON.parse(hc.get_content(fullurl)))
  res.data.url
rescue => e
  $botlogger.error "[#{Time.now.to_s(:db)}] bit.ly API failed."
  $botlogger.error e.message
  $botlogger.error e.backtrace.join("\n")
end

def error_mention(e)
  "@T_Hash なんか #{e.class} とかでエラった＞＜"
end

def fetch_mentions
  latest = Mention.order_by(:posted_at, :desc).first.try(:posted_at) || Time.parse("2012-04-01")
  mentions = Twitter.mentions.select{|m| m.created_at >= latest }
  unless mentions.blank?
    mentions.each do |mention|
      Mention.store(mention)
    end
  end
end

def reply
end

# -*- encoding: UTF-8 -*-
require "rubygems"
require "bundler/setup"
require 'net/http'
require 'nokogiri'
require 'pry'


def atode_entries(tag, page=0)
  uri  = URI.parse("http://b.hatena.ne.jp/Hash/atomfeed?of=#{page*20}&tag=#{tag}")
  http = Net::HTTP.new(uri.host, uri.port)
  req  = Net::HTTP::Get.new(uri.request_uri)
  res  = http.request(req)
end

def getcount(url)
  url  = URI.encode(url)
  uri  = URI.parse("http://api.b.st-hatena.com/entry.count?url=#{url}")
  http = Net::HTTP.new(uri.host, uri.port)
  req  = Net::HTTP::Get.new(uri.request_uri)
  res  = http.request(req)
  res.body.to_i
end

res = atode_entries("%E3%81%82%E3%81%A8%E3%81%A7")
doc = Nokogiri::XML(res.body)

total_count = doc.child.children[1].child.inner_text.scan(/\(\d+\)/).last.gsub(/[()]/,"").to_i

doc.child.children.search("entry").each do |entry|

  # title => "twitter bootstrap railsを使ったら職が見つかり彼女も出来て - ppworks blog"
  # link => "http://ppworks.hatenablog.jp/entry/2012/02/19/033644"
  # blink => "http://b.hatena.ne.jp/Hash/20120307#bookmark-81508937"
  # time => "2012-03-07 03:11:35"
  # tags => ["rails", "design"]
  # bcnt => 49

  title = entry.search("title").inner_text
  link  = entry.search("link")[0].attributes["href"].value
  blink = entry.search("link")[1].attributes["href"].value
  time  = DateTime.parse(entry.search("issued").inner_text).strftime("%Y-%m-%d %X")
  tags  = entry.xpath("dc:subject").map(&:children).map(&:inner_text).reject{|tag| tag == "あとで"}
  bcnt  = getcount(link)
end




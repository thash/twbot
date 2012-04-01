# -*- encoding: UTF-8 -*-
require "rubygems"
require "bundler/setup"
require 'net/http'
require 'nokogiri'
require 'pry'

require 'logger'
require 'mongoid'


### config ---------------------------------
Mongoid.configure do |config|
    config.master = Mongo::Connection.new('localhost', 27017).db("hatetw")
end

@logger = Logger.new('hatetw.log')

### lib -----------------------------
class String
  def as_a_tag
    Tag.find_or_create_by(text: self)
  end
end

### models ---------------------------------
class Bookmark
  include Mongoid::Document
  include Mongoid::Timestamps

  field :title, type: String
  field :link, type: String
  field :blink, type: String
  field :time, type: DateTime
  field :bcnt, type: Integer

  has_and_belongs_to_many :tags

  validates_presence_of :title, :link
  validates_uniqueness_of :blink
end

class Tag
  include Mongoid::Document

  field :text, type: String

  has_and_belongs_to_many :bookmarks
end


### Controller ---------------------------------
def request_bookmarks(tag, page=0)
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


def extract_data(doc)
  entries = []
  doc.child.children.search("entry").each do |entry|

    # title => "twitter bootstrap railsを使ったら職が見つかり彼女も出来て - ppworks blog"
    # link => "http://ppworks.hatenablog.jp/entry/2012/02/19/033644"
    # blink => "http://b.hatena.ne.jp/Hash/20120307#bookmark-81508937"
    # time => "2012-03-07 03:11:35"
    # bcnt => 49
    # tags => ["rails", "design"]

    title = entry.search("title").inner_text
    link  = entry.search("link")[0].attributes["href"].value
    blink = entry.search("link")[1].attributes["href"].value
    time  = DateTime.parse(entry.search("issued").inner_text).strftime("%Y-%m-%d %X")
    bcnt  = getcount(link)
    tags  = entry.xpath("dc:subject").map(&:children).map(&:inner_text).reject{|tag| tag == "あとで"}

    @logger.info "[#{Time.now}]    got: #{time.to_s} -- #{title}"
    @logger.info "[#{Time.now}]    got:   #{blink} (#{bcnt})"

    entries << {
      title: title,
      link: link,
      blink: blink,
      time: time,
      bcnt: bcnt,
      tags: tags # here, it's just texts. need to create Tag object.
    }
  end
  entries
end

def text_to_tag(data)
  data.each do |datum|
    datum[:tags].map!(&:as_a_tag)
  end
end


def exec(tag, page=0)
  @logger.info "[#{Time.now}] exec: #{tag} - p.#{page}"
  res = request_bookmarks(URI.escape(tag), page)
  doc = Nokogiri::XML(res.body)
  data = extract_data(doc)
  data = text_to_tag(data)

  @logger.info "[#{Time.now}] exec: successfully got data. now save them."
  data.map{|datum| Bookmark.create(datum)}
  @logger.info "[#{Time.now}] Bookmark.count => #{Bookmark.count}"
end

def total_count(tag)
  @logger.info "[#{Time.now}] total_count: #{tag}"
  res = request_bookmarks(URI.escape(tag))
  doc = Nokogiri::XML(res.body)
  total = doc.child.search("title").first.text.scan(/\d+/)[-1].to_i
  @logger.info "[#{Time.now}] total_count: => #{total}"
  total
end


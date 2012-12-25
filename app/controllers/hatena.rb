# -*- encoding: UTF-8 -*-
require File.expand_path('../../../config', __FILE__)
Dir::foreach(File.expand_path('../../models/', __FILE__)) { |f|
  next if f == "." || f == ".."
  require  File.expand_path("../../models/#{f}", __FILE__)
}

class TagManager
  attr_accessor :tag, :count

  def initialize(tag)
    @tag = tag
    @count = tagged_entries_count(escaped_tag)
  end

  def escaped_tag
    URI.escape(@tag)
  end

  def all_bookmarks(save=false)
    pages = count.modulo(20).zero? ? count.div(20) : count.div(20) + 1
    bookmarks = []
    0.upto(pages) do |page|
      bookmarks << bookmarks_page_at(page)
      # NOTE: compactのため漏れる可能性が微レ存
      bookmarks.last.compact.each{|b| b.save! } if save
      sleep 2
    end
    bookmarks.flatten
  end

  def create_all_new_bookmarks!
    all_bookmarks(true)
  end

  def bookmarks_page_at(page)
    res = request_bookmarks(escaped_tag, page)
    doc = Nokogiri::XML(res.body)
    bookmarks = []
    doc.child.children.search("entry").each do |entry|
      bookmarks << entry2bookmark(entry)
    end
    bookmarks
  end

  private

  # you should use escaped text inside URL. (NG: あとで, OK: %E3%81%82%E3%81%A8%E3%81%A7)
  # TODO: 200以外の処理
  def request_bookmarks(tag, page=0)
    uri  = URI.parse("http://b.hatena.ne.jp/Hash/atomfeed?of=#{page*20}&tag=#{tag}")
    http = Net::HTTP.new(uri.host, uri.port)
    req  = Net::HTTP::Get.new(uri.request_uri)
    http.request(req)
  end

  # tagを含むブックマーク件数を取得する.
  # title_text => "Hash's Meme Buffer / あとで (765)"
  def tagged_entries_count(tag)
    res = request_bookmarks(tag)
    doc = Nokogiri::XML(res.body)
    title_text = doc.child.search("title").first.text
    title_text.scan(/\d+/)[-1].to_i
  rescue
    nil
  end

  # make a bookmark object from one entry XML
  # sample:
  #   * title: "twitter bootstrap railsを使ったら職が見つかり彼女も出来て - ppworks blog"
  #   *  link: "http://ppworks.hatenablog.jp/entry/2012/02/19/033644"
  #   * blink: "http://b.hatena.ne.jp/Hash/20120307#bookmark-81508937"
  #   *  time: "2012-03-07 03:11:35"
  #   *  bcnt: 49
  #   *  tags: ["rails", "design"]
  def entry2bookmark(entry)
    data = {
      title: entry.search("title").inner_text,
       link: entry.search("link")[0].attributes["href"].value,
      blink: entry.search("link")[1].attributes["href"].value,
       time: DateTime.parse(entry.search("issued").inner_text).strftime("%Y-%m-%d %X"),
       bcnt: nil, # after_initialize
       tags: entry.xpath("dc:subject").map(&:children).map(&:inner_text).map(&:as_a_tag)
    }
    # make bookmark object
    Bookmark.find_or_new(data)
  rescue
    nil
  end

end

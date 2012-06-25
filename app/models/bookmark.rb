# -*- coding: utf-8 -*-
require File.expand_path('../../../lib/hatena.rb', __FILE__)
class Bookmark
  include Mongoid::Document
  include Mongoid::Timestamps

  field :title,      type: String
  field :link,       type: String
  field :blink,      type: String
  field :time,       type: DateTime
  field :bcnt,       type: Integer
  field :remind_cnt, type: Integer, default: 0
  field :closed,     type: Boolean, default: false

  has_and_belongs_to_many :tags
  has_many :botposts, class_name: 'BotPost'

  scope :closed, -> { where(closed: true) }

  validates_presence_of :title, :link, :blink
  validates_uniqueness_of :blink

  index [:time, Mongo::DESCENDING], :background => true

  def self.get_first(num)
    #TODO: refactoring it.
    b = Bookmark.where(closed: false, :remind_cnt.lte => num).order_by(:time, 'asc').first if b.blank?
    return b.present? ? b : nil
  end

  # fetch new bookmarks from hatena,
  # and delete records which don't have "あとで" tag any more.
  def self.refresh
    hatena = HatenaOAuth.new
  end

  def make_tweet(options={user: "T_Hash", short_level: 0})
    txt = ""
    txt += "@#{options[:user]} "
    txt += self.time.to_date.to_s
    txt += " に"
    txt += options[:short_level] == 0 ? tagmapper(5) : tagmapper(1)
    txt += "タグでブクマされた "
    txt += "『" + trunc_title + "』 "
    txt += (shorten(self.link) || link)
    txt += " "
    txt += random_gobi
  end

  def tagmapper(count=5)
    tags[0...count].map(&:text).map{|t| t.gsub(/^@/,"")}.join(",")
  end

  def random_gobi(short_level=0)
    short_level == 0 ?  $settings.mention_gobis.sample(1).first : "な。"
  end

  def trunc_title(limit=30)
    if title.length <= limit
      title
    else
      title[0..limit] + "..."
    end
  end

  def eid
    return nil if blink.blank?
    blink.scan(/\d+/).last.to_i
  end

  # remove tag from comment (summary) and return String
  def tag_removed_summary(tag="あとで")
    hatena  = HatenaOAuth.new
    summary = hatena.edit_get(self.eid)[:entry][:summary]
    # summary.scan(/\[.*?\]/) # => ["[大学]", "[anime]"]
    summary.gsub(/\[#{tag}\]/, '')
  end

  # update Hatena web via Hatena Bookmark API
  def remove_tag_from_hatena!(tag="あとで")
    hatena  = HatenaOAuth.new
    request_xml = make_xml(self.tag_removed_summary)
    hatena.edit_put(self.eid, request_xml)
  end

  # http://developer.hatena.ne.jp/ja/documents/bookmark/apis/atom
  def make_xml(content)
    xml = '<entry xmlns="http://purl.org/atom/ns#"><summary type="text/plain">'
    xml += content
    xml += '</summary></entry>'
  end

end

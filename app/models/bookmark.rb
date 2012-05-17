# -*- coding: utf-8 -*-
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

  validates_presence_of :title, :link, :blink
  validates_uniqueness_of :blink

  index [:time, Mongo::DESCENDING], :background => true

  def self.get_first(num)
    #TODO: refactoring it.
    b = Bookmark.where(closed: false, :remind_cnt.lte => num).order_by(:time, 'asc').first if b.blank?
    return b.present? ? b : nil
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

end

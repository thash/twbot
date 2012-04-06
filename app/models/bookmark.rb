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

  validates_presence_of :title, :link, :blink
  validates_uniqueness_of :blink

  index [:time, Mongo::DESCENDING], :background => true

  def self.get_first(num)
    b = Bookmark.where(closed: false, :remind_cnt.lte => num).order_by(:time, 'asc').first if b.blank?
    return b.present? ? b : nil
  end

  def make_tweet(options={user: "T_Hash", short_level: 0})
    txt = ""
    txt += "@#{options[:user]} "
    txt += self.time.to_date.to_s
    txt += " に"
    txt += options[:short_level] == 0 ? tagmapper(b, 5) : tagmapper(b, 1)
    txt += "タグでブクマされた "
    txt += "『" + truncate(self.title, 30) + "』 "
    txt += shorten(self.link)
    txt += " "
    txt += random_gobi
  end

  def tagmapper(count=5)
    tags[0...count].map(&:text).join(",")
  end

  def random_gobi(short_level=0)
    short_level == 0 ?  $settings.mention_gobis.sample(1).first : "な。"
  end

  def truncate(txt, limit=30)
    if txt.length <= limit
      txt
    else
      txt[0..30] + "..."
    end
  end
end

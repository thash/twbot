# -*- coding: utf-8 -*-
class Mention
  include Mongoid::Document

  field :status_id,   type: Integer
  field :from_user,   type: String
  field :in_reply_to, type: Integer
  field :text,        type: String
  field :posted_at,   type: Time
  field :processed,   type: Boolean, default: false

  validates_uniqueness_of :status_id

  def self.store(mention)
    create!({
      status_id: mention.id,
      from_user: mention.user.screen_name,
      in_reply_to: mention.in_reply_to_status_id,
      text: mention.text,
      posted_at: mention.created_at
    })
  end

  def self.get_unprocessed(limit=3)
    order_by(:posted_at, :desc).limit(limit)
  end

  def type
    case text
    when /(読んだ)|(よんだ)|(完了)|(close)/
      :read
    when /(うどん)/
      :udon
    when /(リンク切れ)/
      :dead_link
    when /(thx)|(さんくす)|(サンクス)|(ありがと)/
      :thanks
    when /(ごめん)|(すまん)|(すみません)|(申し訳ない)/
      :sorry
    when /^RT @bot_t_hash/
      :retweet
    else
      # TODO: add the case when in_reply_to_status_id.blank?
      :unknown
    end
  end



end

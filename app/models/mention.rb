# -*- coding: utf-8 -*-
class Mention
  include Mongoid::Document

  field :status_id,   type: Integer
  field :from_user,   type: String
  field :in_reply_to, type: Integer
  field :text,        type: String
  field :posted_at,   type: Time

  validates_uniqueness_of :status_id

  def self.store(mention)
    Mention.create!({
      status_id: mention.id,
      from_user: mention.user.screen_name,
      in_reply_to: mention.in_reply_to_status_id,
      text: mention.text,
      posted_at: mention.created_at
    })
  end

end

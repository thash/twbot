# -*- coding: utf-8 -*-
class BotPost
  include Mongoid::Document
  include Mongoid::Timestamps

  field :status_id,   type: Integer
  field :to_user,   type: Integer # twitter user_id
  field :in_reply_to, type: Integer
  field :text,        type: String
  field :posted_at,   type: Time

  validates_uniqueness_of :status_id

  def self.store(status)
    BotPost.create({
      status_id: status.id,
      to_user: status.in_reply_to_user_id,
      in_reply_to: status.in_reply_to_status_id,
      text: status.text,
      posted_at: status.created_at})
  rescue => e
    $botlogger.error "[#{Time.now.to_s(:db)}] Save to BotPost failed."
    $botlogger.error e.message
    $botlogger.error e.backtrace.join("\n")
  end
end

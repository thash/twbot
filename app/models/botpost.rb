# -*- coding: utf-8 -*-
class BotPost
  include Mongoid::Document
  include Mongoid::Timestamps

  field :status_id,   type: Integer
  field :to_user,   type: Integer # twitter user_id
  field :in_reply_to, type: Integer
  field :text,        type: String
  field :posted_at,   type: Time

  belongs_to :bookmark

  validates_uniqueness_of :status_id

  def self.store(status, bookmark=nil)
    BotPost.create({
      status_id: status.id,
      bookmark_id: bookmark.try(:id),
      to_user: status.in_reply_to_user_id,
      in_reply_to: status.in_reply_to_status_id,
      text: status.text,
      posted_at: status.created_at})
  rescue => e
    $botlogger.error "[#{Time.now.to_s(:db)}] Save to BotPost failed."
    $botlogger.error e.message
    $botlogger.error e.backtrace.join("\n")
  end

  def self.find_by_status_id(status_id)
    BotPost.where(status_id: status_id).first || raise(Mongoid::Errors::DocumentNotFound.new(self.class, status_id.to_s))
  end
end

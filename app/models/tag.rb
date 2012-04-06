# -*- coding: utf-8 -*-
class Tag
  include Mongoid::Document

  field :text, type: String

  has_and_belongs_to_many :bookmarks
  validates_uniqueness_of :text

  index :text, :background => true
end

class String
  def as_a_tag
    Tag.find_or_create_by(text: self)
  end
end

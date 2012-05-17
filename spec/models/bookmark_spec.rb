# -*- coding: utf-8 -*-
require 'spec_helper'

describe 'Bookmark' do
  it { Bookmark.class.should eq Class }

  describe '#tagmapper' do
    before(:all) do
      @b = Bookmark.create({
        title: "twitter bootstrap railsを使ったら職が見つかり彼女も出来て - ppworks blog",
        link:  "http://ppworks.hatenablog.jp/entry/2012/02/19/033644",
        blink: "http://b.hatena.ne.jp/Hash/20120307#bookmark-81508937",
        time: "2012-03-07 03:11:35",
        bcnt: 49,
        tags: ["hoge".as_a_tag, "@sotarok".as_a_tag]
      })
    end

    it { Bookmark.count.should eq 1 }
    #it 'should remove @ when tag is @someone' do
    #end
  end
end

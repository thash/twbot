# -*- coding: utf-8 -*-
require 'spec_helper'

describe 'Bookmark' do
  it { Bookmark.class.should eq Class }

  describe '#tagmapper' do
    let(:base_params) {{
      title: "twitter bootstrap railsを使ったら職が見つかり彼女も出来て - ppworks blog",
      link:  "http://ppworks.hatenablog.jp/entry/2012/02/19/033644",
      blink: "http://b.hatena.ne.jp/Hash/20120307#bookmark-81508937",
      time: "2012-03-07 03:11:35",
      bcnt: 49
    }}

    it 'should generate string from tags' do     
      params = base_params.merge( tags: ["hoge".as_a_tag, "fuga".as_a_tag] )
      Bookmark.create(params)
      b = Bookmark.first
      b.tagmapper.should eq "hoge,fuga"
    end
    it 'should remove @ when tag contains @someone' do     
      params = base_params.merge( tags: ["hoge".as_a_tag, "@ppworks".as_a_tag] )
      Bookmark.create(params)
      b = Bookmark.first
      b.tagmapper.should eq "hoge,ppworks"
    end
  end
end

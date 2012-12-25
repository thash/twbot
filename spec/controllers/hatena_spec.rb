# coding: utf-8
require 'spec_helper'

describe TagManager do
  describe '#initialize' do
    before do
      TagManager.any_instance.stub(:tagged_entries_count).and_return(10)
      @tag_mamager = TagManager.new("たぐ")
    end
    it { @tag_mamager.tag.should eq "たぐ" }
    it { @tag_mamager.tagged_entries_count.should eq 10 }
  end
end

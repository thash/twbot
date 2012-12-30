# -*- encoding: UTF-8 -*-

Dir::foreach(File.expand_path('../app/controllers/', __FILE__)) { |f|
  next if f == "." || f == ".."
  require  File.expand_path("../app/controllers/#{f}", __FILE__)
}
spec = Bundler.load.specs.find{|s| s.name == "mongoid" }
raise GemNotFound, "Cound not find specified gem" unless spec
#local => "/Users/hash/work/twitter/bot/.bundle/ruby/1.9.1/gems/mongoid-2.4.6"
#remote=> "/u/apps/twbot/shared/bundle/ruby/1.9.1/gems/mongoid-2.4.6"
load spec.full_gem_path + "/lib/mongoid/railties/database.rake"


namespace :bot do
  task :test do
    bot = Bot.new
    bot.test
  end

  task :remind_bookmark do
    bot = Bot.new
    bot.remind_bookmark
  end

  task :reply do
    bot = Bot.new
    bot.fetch_mentions
    bot.react_to_mentions(1)
  end
end

namespace :hatena do
  namespace :bookmarks do
    task :create_all do
      tag = ENV['TAG'] || '縺ゅ→縺ｧ'
      tag_mamager = TagManager.new(tag)
      tag_mamager.create_all_new_bookmarks!
    end
  end

  task :push_to_web do
    target = Bookmark.closed.not_pushed_yet.limit(3)
    target.each do |b|
      $logger.info "[#{Time.now.to_s(:db)}] remove [tag] from #{b.blink}"
      res = b.remove_tag_from_hatena!
      $logger.info "[#{Time.now.to_s(:db)}] #{res.to_s}"
      sleep 10
    end
  end
end

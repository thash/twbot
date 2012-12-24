Dir::foreach(File.expand_path('../app/controllers/', __FILE__)) { |f|
  next if f == "." || f == ".."
  require  File.expand_path("../app/controllers/#{f}", __FILE__)
}
spec = Bundler.load.specs.find{|s| s.name == "mongoid" }
raise GemNotFound, "Cound not find specified gem" unless spec
#local => "/Users/hash/work/twitter/bot/.bundle/ruby/1.9.1/gems/mongoid-2.4.6"
#remote=> "/u/apps/twbot/shared/bundle/ruby/1.9.1/gems/mongoid-2.4.6"
load spec.full_gem_path + "/lib/mongoid/railties/database.rake"


namespace :hatetw do
  task :fetch do
    tag = ENV['TAG']
    total = total_count(tag)
    divmod = total.divmod(20)
    pages = divmod[1] == 0 ? divmod[0] : divmod[0] + 1
    for i in 0..pages do
      exec(tag, i)
      sleep 2
    end
  end

  task :test do
    test
  end

  task :update do
    update
  end

  task :reply do
    fetch_mentions
    react_to_mentions(1)
  end
end

namespace :hatena do
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

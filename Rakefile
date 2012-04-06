Dir::foreach(File.expand_path('../app/triggers/', __FILE__)) { |f|
  next if f == "." || f == ".."
  require  File.expand_path("../app/triggers/#{f}", __FILE__)
}
load "./vendor/bundle/ruby/1.9.1/gems/mongoid-2.4.6/lib/mongoid/railties/database.rake"

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

  task :update do
    update
  end
end

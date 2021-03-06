require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require File.expand_path(File.dirname(__FILE__) + "/../lib/esodes")

env :PATH, ENV['PATH']
#set :bundle_command, "/home/deploy/.rbenv/shims/bundle exec"


set :environment, :production
set :output, "#{Rails.root}/log/cron_log.log"

every '*/5 7-11,12-17 * * 1-6' do
  rake "cronjobs:esod_sync"
end
every '30 6,11,17 * * 1-5' do
  rake "cronjobs:esod_sync_big"
end

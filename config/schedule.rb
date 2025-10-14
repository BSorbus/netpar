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

every '15 */6 * * *' do
  rake "cronjobs:testportal_set_tests"
end
every '30 5 * * *' do
  rake "cronjobs:testportal_clean_tests"
end
# every '0 0 * * *' do
#   rake "cronjobs:testportal_activate"
# end

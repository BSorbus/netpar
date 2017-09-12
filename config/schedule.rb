# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever


require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require File.expand_path(File.dirname(__FILE__) + "/../lib/esodes")
#require File.expand_path(File.dirname("netpar/config") + "/environment")

set :environment, :production

# To jest OK!
# set :output, "#{Rails.root}/log/cron_log.log"
# ...ale zmieniam ze względu na 'mine'
set :output, "home/bogdan/netpar/current/log/cron_log.log"


#every 15.minutes do
#  #rake 'db:seed:esod_whenever'
#  rake "cronjobs:esod_sync"
#end

#every '*/15 7-17 * * *' do
#every '*/15 7-17 * * 1-6' do
#  rake "cronjobs:esod_sync"
#end

#every '*/10 7-11,12-17 * * 1-6' do
#  rake "cronjobs:esod_sync"
#end
every '*/5 7-11,12-17 * * 1-6' do
  rake "cronjobs:esod_sync"
end
every '30 6,11,17 * * 1-5' do
  rake "cronjobs:esod_sync_big"
end

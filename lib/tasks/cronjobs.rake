# lib/tasks/cronjobs.rake
require 'esodes'

namespace :cronjobs do
  desc "Synchronize data with system ESOD"
  task esod_sync: :environment do
    Esodes::esod_whenever_sprawy(15)
    #users = User.all
    #users.each do |user|
    #  puts user.email if user.esod_encryped_password.present?
    #end
  end

end
# lib/tasks/cronjobs.rake
require 'esodes'

namespace :cronjobs do
  desc "Synchronize data with system ESOD"
  task esod_sync: :environment do
    role = Role.find_by(name: 'ESOD - Menadżer Dokumentów')
    #Esodes::esod_whenever_sprawy(15)
    role.users.each do |user|
      Esodes::esod_whenever_sprawy(user.id, 2.days)
    end
  end
  task esod_sync_big: :environment do
    role = Role.find_by(name: 'ESOD - Menadżer Dokumentów')
    #Esodes::esod_whenever_sprawy(15)
    role.users.each do |user|
      Esodes::esod_whenever_sprawy(user.id, 30.days)
    end
  end

end
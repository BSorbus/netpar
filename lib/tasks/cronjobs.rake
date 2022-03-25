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
  desc "Big synchronize data with system ESOD"
  task esod_sync_big: :environment do
    role = Role.find_by(name: 'ESOD - Menadżer Dokumentów')
    #Esodes::esod_whenever_sprawy(15)
    role.users.each do |user|
      Esodes::esod_whenever_sprawy(user.id, 30.days)
    end
  end
  desc "Create tests in TestPortal and save keys into NETPAR"
  task testportal_set_tests: :environment do
    ApiTestportalTest::testportal_whenever_tests_set
  end
  desc "Clean tests in TestPortal and Netpar"
  task testportal_clean_tests: :environment do
    ApiTestportalTest::testportal_whenever_tests_clean
  end
  desc "Activate tests in TestPortal"
  task testportal_activate: :environment do
    ApiTestportalTest::testportal_whenever_tests_activate
  end
end
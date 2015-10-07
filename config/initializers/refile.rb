require "refile"
Refile.configure do |config|
  #config.store = Refile::Postgres::Backend.new(proc { ActiveRecord::Base.connection.raw_connection }, max_size: 1.megabytes )
  config.store = Refile::Postgres::Backend.new(proc { ActiveRecord::Base.connection.raw_connection } )
end

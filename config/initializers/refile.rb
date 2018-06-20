require "refile"
Refile.configure do |config|
  connection = lambda { |&blk| ActiveRecord::Base.connection_pool.with_connection { |con| blk.call(con.raw_connection) } }
  config.store = Refile::Postgres::Backend.new(connection)
  # config.direct_upload = ["cache"]
  # config.allow_origin = "*"
  # config.logger = Logger.new(STDOUT)
  # config.mount_point = "attachments"
  # config.automount = false
  # config.content_max_age = 60 * 60 * 24 * 365
  # config.types[:image] = Refile::Type.new(:image, content_type: %w[image/jpeg image/gif image/png])  
end

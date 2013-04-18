require 'heroku/command'
require 'heroku'
require 'heroku/client/pgbackups'
#require 'aws/s3'

#itcutility:backup
namespace :itcutility do
  desc "backup"
  task :backup => :environment do
    Rails.logger.info("Backup started @ #{Time.now}")
    # inspect
    #puts "DATABASE_URL = #{ENV["DATABASE_URL"]}"
    #puts "HEROKU_BACKUP_DATABASES = #{ENV["HEROKU_BACKUP_DATABASES"]}"
    #puts "PGBACKUPS_URL = #{ENV["PGBACKUPS_URL"]}"
    client = Heroku::Client::Pgbackups.new(ENV["PGBACKUPS_URL"])
      db = "DATABASE_URL"
      db_url = ENV[db]
      Rails.logger.info("backing up #{db}")
      client.create_transfer(db_url, db, nil, "BACKUP", :expire => true)
    #end
    Rails.logger.info("Backup complete @ #{Time.now}")
  end

  desc "loadem"
  task :loadem => :environment do
    for i in 1..1000
      Filler.create([:uid => i, :description => "just another test record to load up the database."])  
    end
  end
end

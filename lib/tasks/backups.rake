require "heroku/command"
require 'heroku/client/pgbackups'
require "aws/s3"

#itcutility:backup
namespace :itcutility do
  desc "create a pg_dump"
  task :backup => :environment do
    puts "All Fired Up"
    config = YAML.load(File.open("#{Rails.root}/config/amazon_s3.yml"))[Rails.env]
    APP_NAME = config[ "heroku_app_name" ]
    puts APP_NAME
    puts "PGBACKUPS_URL = #{ENV["PGBACKUPS_URL"]}"
    puts "PGBACKUPS_DATABASE_URL = #{ENV["PGBACKUPS_DATABASE_URL"]}"
    puts "DATABASE_URL = #{ENV["DATABASE_URL"]}"
    #puts ENV["HEROKU_USERNAME"]
    #puts ENV["HEROKU_API_KEY"]
    
#=begin
    # versopm 2
    Rails.logger.info("Backup started @ #{Time.now}")
    
    # version 2
    pgbackups_url = ENV["PGBACKUPS_URL"] 
    db_url = ENV["PGBACKUPS_DATABASE_URL"] || ENV["DATABASE_URL"]
    puts "pgbackups_URL = #{pgbackups_url}, db_url = #{db_url}"
    
    client = Heroku::Client::Pgbackups.new(pgbackups_url)
    
    puts "create_transfer"
    @pgbackup = client.create_transfer(db_url, db_url, nil, "BACKUP", :expire => true)
    puts "backup id = #{@pgbackup["id"]}"
    @pgbackup = client.get_transfer(@pgbackup["id"])
    
    puts("Opening S3 connection") # Rails.logger.info
    
    AWS::S3::Base.establish_connection!(
      :access_key_id => config["access_key_id"],
      :secret_access_key => config["secret_access_key"]
    )
    BACKUP_BUCKET_NAME = config["backup_bucket_name"]
 
    puts "bucket find/create..."
    begin
      AWS::S3::Bucket.find(BACKUP_BUCKET_NAME)
    rescue AWS::S3::NoSuchBucket
      AWS::S3::Bucket.create(BACKUP_BUCKET_NAME)
    end

    #puts("Opening new pg_dump")
    #pg_backup_client = cient.send(:pgbackup_client) # protected
    puts "open..."
    local_pg_dump = open(@pgbackup["public_url"]) # pg_backup_client.get_latest_backup["public_url"])
    puts("Finished opening new pg_dump")
 
    puts("Uploading to S3 bucket")
    AWS::S3::S3Object.store(Time.now.to_s(:number), local_pg_dump, BACKUP_BUCKET_NAME)
 
    puts("Backup completed @ #{Time.now}")


=begin    
    puts "credentials"
    Heroku::Auth.credentials = [ ENV["HEROKU_USERNAME"], ENV["HEROKU_API_KEY"] ]
 
    puts("Capturing new pg_dump")
 
    Heroku::Command.load
    puts "new..."
    pg_backup = Heroku::Command::Pgbackups.new([], { :app => APP_NAME, :expire => true }).capture
    puts "capturing..." # ERROR HERE!
    #pg_backup.capture
 
    puts("Opening S3 connection") # Rails.logger.info
    
    AWS::S3::Base.establish_connection!(
      :access_key_id => config["access_key_id"],
      :secret_access_key => config["secret_access_key"]
    )
    BACKUP_BUCKET_NAME = config["backup_bucket_name"]
 
    puts "bucket find/create..."
    begin
      AWS::S3::Bucket.find(BACKUP_BUCKET_NAME)
    rescue AWS::S3::NoSuchBucket
      AWS::S3::Bucket.create(BACKUP_BUCKET_NAME)
    end
 
    puts("Opening new pg_dump")
    pg_backup_client = pg_backup.send(:pgbackup_client) # protected
    puts "open..."
    local_pg_dump = open(pg_backup_client.get_latest_backup["public_url"])
    puts("Finished opening new pg_dump")
 
    puts("Uploading to S3 bucket")
    AWS::S3::S3Object.store(Time.now.to_s(:number), local_pg_dump, BACKUP_BUCKET_NAME)
 
    puts("Backup completed @ #{Time.now}")
=end
    puts "test"

  end
end

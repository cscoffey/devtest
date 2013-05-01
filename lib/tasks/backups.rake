require "heroku/command"
require "aws/s3"

#itcutility:backup
namespace :itcutility do
  desc "create a pg_dump"
  task :backup => :environment do
    puts "All Fired Up"
    config = YAML.load(File.open("#{Rails.root}/config/amazon_s3.yml"))[Rails.env]
    APP_NAME = config[ "heroku_app_name" ]
#=begin
     
    Rails.logger.info("Backup started @ #{Time.now}")
    Heroku::Auth.credentials = [ ENV["HEROKU_USERNAME"], ENV["HEROKU_API_KEY"] ]
 
    Rails.logger.info("Capturing new pg_dump")
 
    Heroku::Command.load
    pg_backup = Heroku::Command::Pgbackups.new([], { :app => APP_NAME, :expire => true })
    pg_backup.capture
 
    Rails.logger.info("Opening S3 connection")
    
    AWS::S3::Base.establish_connection!(
      :access_key_id => config["access_key_id"],
      :secret_access_key => config["secret_access_key"]
    )
    BACKUP_BUCKET_NAME = config["backup_bucket_name"]
 
    begin
      AWS::S3::Bucket.find(BACKUP_BUCKET_NAME)
    rescue AWS::S3::NoSuchBucket
      AWS::S3::Bucket.create(BACKUP_BUCKET_NAME)
    end
 
    Rails.logger.info("Opening new pg_dump")
    pg_backup_client = pg_backup.send(:pgbackup_client) # protected
    local_pg_dump = open(pg_backup_client.get_latest_backup["public_url"])
    Rails.logger.info("Finished opening new pg_dump")
 
    Rails.logger.info("Uploading to S3 bucket")
    AWS::S3::S3Object.store(Time.now.to_s(:number), local_pg_dump, BACKUP_BUCKET_NAME)
 
    Rails.logger.info("Backup completed @ #{Time.now}")
#=end
    puts "test"

  end
end

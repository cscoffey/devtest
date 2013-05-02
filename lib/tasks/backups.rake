# IT Cadre Utilities

require "heroku/command"
require 'heroku/client/pgbackups'
require "aws/s3"

#itcutility:backup
namespace :itcutility do
  desc "create a pg_dump"
  task :backup => :environment do
    # REQUIRES THESE KEYS IN ENVIRONMENT:
    # S3_ACCESS_KEY_ID
    # S3_SECRET_ACCESS_KEY
    # S3_BACKUP_BUCKET_NAME
    # S3_HEROKU_APP_NAME
    #    
    Rails.logger.info("Backup started @ #{Time.now}")
    puts("Backup started @ #{Time.now}") # for console use

    config = { "access_key_id" => ENV['S3_ACCESS_KEY_ID'],
               "secret_access_key" => ENV['S3_SECRET_ACCESS_KEY'],
               "backup_bucket_name" => ENV['S3_BACKUP_BUCKET_NAME'],
               "heroku_app_name" => ENV['S3_HEROKU_APP_NAME']
    }
    
    # YAML.load(File.open("#{Rails.root}/config/amazon_s3.yml"))[Rails.env]
    APP_NAME = config[ "heroku_app_name" ]
    #puts APP_NAME
    #puts "PGBACKUPS_URL = #{ENV["PGBACKUPS_URL"]}"
    #puts "PGBACKUPS_DATABASE_URL = #{ENV["PGBACKUPS_DATABASE_URL"]}"
    #puts "DATABASE_URL = #{ENV["DATABASE_URL"]}"

    pgbackups_url = ENV["PGBACKUPS_URL"] 
    db_url = ENV["PGBACKUPS_DATABASE_URL"] || ENV["DATABASE_URL"]
    #puts "pgbackups_URL = #{pgbackups_url}, db_url = #{db_url}"
    
    client = Heroku::Client::Pgbackups.new(pgbackups_url)
    
    # code found at github.com/heroku/heroku/blob/master/lib/heroku/client/pgbackups.rb
    @pgbackup = client.create_transfer(db_url,                # from_url
                                       db_url,              # from_name
                                       nil,                   # to_url
                                       "BACKUP",  # to_name
                                       :expire => true)       # options (:expire => true/false)
    #puts "backup id = #{@pgbackup["id"]}"
    #puts "@pgbackup = #{@pgbackup.inspect}"
    @pgbackup = client.get_transfer(@pgbackup["id"])
    #puts "@pgbackup now = #{@pgbackup.inspect}"

    if @pgbackup["errors"] == nil
      until @pgbackup["finished_at"] 
        sleep 1
        @pgbackup = client.get_transfer(@pgbackup["id"])
      end
    end
    #puts "@pgbackup now = #{@pgbackup.inspect}"

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

    local_pg_dump = open(@pgbackup["public_url"]) # pg_backup_client.get_latest_backup["public_url"])
    backup_name = "BACKUP_#{APP_NAME}_#{Time.now.to_s(:number)}"
    AWS::S3::S3Object.store(backup_name, local_pg_dump, BACKUP_BUCKET_NAME)
 
    puts("Backup completed @ #{Time.now}")
    Notifier.debug_email("Backup (#{backup_name}) completed @ #{Time.now}", 'chuck.coffey@itcadre.com', 'https://' + ActionMailer::Base.default_url_options[:host] )
  end
end

require 'yaml'

namespace :db do
  desc 'Restore DB dump file to local'
  task :restore, [:file] => :environment do |_t, args|
    dump_file = args[:file] || 'latest.dump'

    # Create DB in case it doesn't exist.
    system 'rake db:create'

    # Remove the existing dump file.
    FileUtils.rm(dump_file, force: true)

    # Download latest.dump from Heroku server.
    system 'heroku pg:backups:download'

    # Read development DB configs.
    database_yml = YAML.load_file("#{Rails.root}/config/database.yml")
    host = database_yml['development']['host']
    database = database_yml['development']['database']
    username = database_yml['development']['username']

    command = "pg_restore --verbose --clean --no-acl --no-owner -h #{host} -U #{username} -W -d #{database} #{dump_file}"
    puts "Executing: #{command}"
    system command

    # Run db:migrate.
    system 'rake db:migrate'
  end

  desc 'Convert development DB to Rails test fixtures'
  task to_fixtures: :environment do
    TABLES_TO_SKIP = %w[ar_internal_metadata delayed_jobs schema_info schema_migrations].freeze

    begin
      ActiveRecord::Base.establish_connection
      ActiveRecord::Base.connection.tables.each do |table_name|
        next if TABLES_TO_SKIP.include?(table_name)

        conter = '000'
        file_path = "#{Rails.root}/test/fixtures/#{table_name}.yml"
        File.open(file_path, 'w') do |file|
          rows = ActiveRecord::Base.connection.select_all("SELECT * FROM #{table_name}")
          data = rows.each_with_object({}) do |record, hash|
            suffix = record['id'].blank? ? conter.succ! : record['id']
            hash["#{table_name.singularize}_#{suffix}"] = record
          end
          puts "Writing table '#{table_name}' to '#{file_path}'"
          file.write(data.to_yaml)
        end
      end
    ensure
      ActiveRecord::Base.connection.close if ActiveRecord::Base.connection
    end
  end
end

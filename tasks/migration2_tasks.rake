namespace :db do
  desc "Remigrate - execute one migration file. Target specific version with VERSION=x"
  task :remigrate => :environment do
    version = ENV["VERSION"].to_i
    unless version > 0
      raise "Remigration error: VERSION=x should be over zero. (current: #{version})"
    end

    files = Dir[RAILS_ROOT + "/db/migrate/*"].grep(%r{db/migrate/0*#{version}_[^/]+$})
    files.each do |file|
      require file
      name = File.basename(file).scan(/^[0-9]+_([_a-z0-9]*).rb/).first.first rescue nil
      unless name
        raise "Remigration bug? cannot find any class names from migration file (#{file})"
      end

      klass = name.camelize.constantize
      klass.down
      klass.up
    end
  end
end

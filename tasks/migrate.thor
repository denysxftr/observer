require './main'

Sequel.extension(:migration)

class Migrations < Thor
  desc 'perform', 'Migrate DB to latest version'
  def perform
    Sequel::Migrator.run(DB, 'migrations')
  end

  desc 'rollback', 'Migrate DB one step down'
  def rollback
    if DB.tables.include?(:schema_info)
      version = DB[:schema_info].first[:version]
      Sequel::Migrator.run(DB, 'migrations', target: (version - 1))
    else
      puts 'Cannot rollback'
    end
  end

  desc 'reset', 'Perform migration reset (full rollback and migration)'
  def reset
    Sequel::Migrator.run(DB, 'migrations', target: 0)
    perform
  end
end

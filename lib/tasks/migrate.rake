require 'nokogiri'
require 'fileutils'

require 'migrations/entity'
require 'migrations/parser'
require 'migrations/property'
require 'migrations/relationship'
require 'migrations/io'
require 'migrations/generator'

namespace :db do
  desc 'Generate a version of the current database model as described in the models.'
  task :migrate do
    schema_xml = MotionData::Migrations::Generator.build
    MotionData::Migrations::IO.write(schema_xml)
  end

  desc 'Go back to the previous version of the database model.'
  task :rollback do
    if version = MotionData::Migrations::IO.current_schema_version
      if version == 1
        puts "! Can't rollback schema when version is 1."
      else
        schema = MotionMigrate::IO.current_schema
        MotionMigrate::IO.write_current_schema(version - 1)
        FileUtils.rm_rf(schema)
        puts "# Data model rolled back to version #{version - 1}."
      end
    else
      puts "! No schema found in this project."
    end
  end

  namespace :schema do
    desc 'Dump the current version of the database model scheme.'
    task :dump do
      if current_schema = MotionData::Migrations::IO.current_schema
        puts File.open(File.join(current_schema, "contents")).read
      else
        puts "! No schema found in this project."
      end
    end

    desc 'Show the current version of the database model scheme.'
    task :version do
      if version = MotionData::Migrations::IO.current_schema_version
        puts "# Data model is currently at version #{version}."
      else
        puts "! No schema found in this project."
      end
    end
  end
end

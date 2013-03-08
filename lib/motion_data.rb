module MotionData
end

unless defined?(Motion::Project::Config)
  raise "This file must be required within a RubyMotion project Rakefile."
end

Motion::Project::App.setup do |app|
  Dir.glob(File.join(File.dirname(__FILE__), 'motion_data/*.rb')).each do |file|
    app.files.unshift(file)
  end
  app.frameworks += ['CoreData']
end

# Include rake files
Dir.glob(File.join(File.dirname(__FILE__), "tasks/**/*.rake")) do |task|
  import task
end

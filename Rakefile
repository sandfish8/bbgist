desc "create uploads directory"
task :create_uploads_directory do
  dir = File.join(File.dirname(__FILE__), "uploads")
  unless File.exists?(dir)
    Dir.mkdir(dir)
  end
end

task :default => :create_uploads_directory

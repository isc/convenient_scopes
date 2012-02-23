require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "convenient_scopes"
    gem.summary = %Q{Dynamic scopes by convention for ActiveRecord 3}
    gem.description = %Q{Dynamic scopes by convention for ActiveRecord 3}
    gem.email = "isc@massivebraingames.com"
    gem.homepage = "http://github.com/isc/convenient_scopes"
    gem.authors = ["Ivan Schneider"]
    gem.add_runtime_dependency "activerecord", ">= 3.0.4"
    gem.add_development_dependency "shoulda", ">= 0"
    gem.add_development_dependency "sqlite3"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/test_*.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

# task :test => :check_dependencies

task :default => :test

begin
  require 'rdoc/task'
  Rake::RDocTask.new do |rdoc|
    version = File.exist?('VERSION') ? File.read('VERSION') : ""

    rdoc.rdoc_dir = 'rdoc'
    rdoc.title = "convenient_scopes #{version}"
    rdoc.rdoc_files.include('README*')
    rdoc.rdoc_files.include('lib/**/*.rb')
  end
rescue LoadError
  puts "rdoc requiring snafu"
end

require "bundler/gem_tasks"

require "rspec/core/rake_task"
RSpec::Core::RakeTask.new do |t|
  t.pattern = 'spec/**/*_spec.rb'
end

require "yard"
YARD::Rake::YardocTask.new do |t|
  t.files = ["lib/**/*.rb", "lib/**/ext/**/*.c"]
end

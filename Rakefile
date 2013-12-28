require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'test'
end

desc "Run tests"
task :default => :test

require 'rdoc/task'

RDoc::Task.new do |rdoc|
  rdoc.main = "README.rdoc"
  rdoc.rdoc_files.include("README.rdoc", "lib/bibout.rb", "lib/bibout/bibtex.rb", "lib/bibout/erb_binding.rb")
  rdoc.generator = 'bootstrap'
  rdoc.rdoc_dir = 'rdoc'
end


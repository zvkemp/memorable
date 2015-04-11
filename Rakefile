require "bundler/gem_tasks"
require 'rake/testtask'

Rake::TestTask.new do |t|
  #t.libs << 'lib/memorable' << 'spec/spec_helper'
  t.test_files = FileList['spec/lib/**/*_spec.rb']
end

task default: :test
task spec: :test

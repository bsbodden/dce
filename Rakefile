#!/usr/bin/env rake
begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

require 'rspec/core'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new

task :default => :spec
task :test => :spec

desc "execute cli.rb"
task :go do
  ruby "./cli.rb"
end

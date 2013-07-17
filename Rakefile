require "rubygems"
require 'rake'
require 'rake/testtask'
require_relative 'lib/app'

task :default => :test

desc "run tests"
task :test do
  # just run tests, nothing fancy
  Dir["test/**/*.rb"].sort.each { |test|  load test }
end

desc "Build files and upload to s3"
task :build do
  PicoAppz.new.build
end

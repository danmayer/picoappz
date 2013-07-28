source 'https://rubygems.org'
gem 'rake'
gem 'sinatra'
gem 'json'
gem 'rack-flash3'
gem 'fog'
gem 'rest-client'
gem 'erubis'

# Prevent installation on Heroku with
# heroku config:add BUNDLE_WITHOUT="development:test"
group :development, :test do
   gem 'rack-test'
   gem 'mocha'
end

if RbConfig::CONFIG['host_os'] =~ /darwin/
  group :development do
    gem 'pry'
    gem 'foreman'
  end
end

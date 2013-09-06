require 'json'
require 'fileutils'
require 'rack-flash'
require_relative 'lib/pico_appz'

set :public_folder, File.dirname(__FILE__) + '/public'
set :root, File.dirname(__FILE__)
enable :logging
enable :sessions
use Rack::Flash, :sweep => true

DEFERRED_SERVER_ENDPOINT = "http://git-hook-responder.herokuapp.com/"
DEFERRED_SERVER_TOKEN    = ENV['DEFERRED_ADMIN_TOKEN']

helpers do
  def protected!
    unless authorized?
      response['WWW-Authenticate'] = %(Basic realm="Testing HTTP Auth")
      throw(:halt, [401, "Not authorized\n"])
    end
  end

  def authorized?
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == ['admin', 'responder']
  end
end

#before { protected! if request.path_info == "/" && request.request_method == "GET" && ENV['RACK_ENV']!='test' }

get '/' do
  flash[:notice] = "your up and running"
  erb :index
end

post '/publish' do
  forward_to_deferred_server('danmayer/picoappz','HEAD')
end

private

def forward_to_deferred_server(project, commit, options = {})
  request_timeout = options.fetch(:timeout){ 6 }
  request_open_timeout    = options.fetch(:open_timeout){ 6 }
  resource = RestClient::Resource.new(DEFERRED_SERVER_ENDPOINT, 
                                      :timeout => request_timeout, 
                                      :open_timeout => request_open_timeout)
  
  resource.post(:signature => DEFERRED_SERVER_TOKEN,
                :project => project,
                :commit => commit,
                :command => 'bundle exec rake build')
rescue RestClient::RequestTimeout
  puts "timed out during deferred-server hit"
end


require 'sinatra/base'
require 'haml'
require 'rack/contrib'
require 'json'

module Sinatra
  class Dtracy < Sinatra::Base
    
    set :root, File.dirname(__FILE__) + '/'
    set :raise_errors, true
    set :static, true
    set :reload, true
    
    use Rack::JSONP
    use Rack::Probe

    get '/' do
      haml :index
    end

    get '/updates' do
      events = Rack::Probe.events
      idx = params[:idx].to_i
      sleep 1 while idx >= (length = events.length) # Take naps until there's new data
      events = events[idx..-1] || []
      {:idx => length, :data => events }.to_json
    end
  end
end
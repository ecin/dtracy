require 'sinatra/base'
require 'haml'
require 'rack/contrib'

module Sinatra
  class Dtracy < Sinatra::Base
    
    set :root, File.dirname(__FILE__) + '/'
    set :raise_errors, true
    set :static, true
    
    use Rack::JSONP
    
    get '/' do
      haml :index
    end

    get '/updates' do
      params[:id] ||= 1
      Event.all( :id.gt => params[:id])
    end
  end
end
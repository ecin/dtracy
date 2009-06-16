require 'sinatra/base'
require 'haml'

module Sinatra
  class Dtracy < Sinatra::Base
    
    set :root, File.dirname(__FILE__) + '/'
    set :raise_errors, true
    set :static, true
    
    get '/' do
      haml :index
    end

    get '/updates/:id' do
      params[:id] ||= 1
      Event.all( :id.gt => params[:id])
    end
  end
end
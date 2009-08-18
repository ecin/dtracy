require 'sinatra/base'
require 'haml'
require 'rack/contrib'
require 'json'

gem 'ruby-dtrace', '>= 0.2.7'
require 'dtrace'

require File.expand_path( File.dirname(__FILE__) + '/dtracy/dtective' )

module Dtracy
  class App < Sinatra::Base

    set :root, File.dirname(__FILE__) + '/dtracy'
    set :raise_errors, true
    set :static, true
    set :app_file, __FILE__
    set :reload, true

    use Rack::JSONP
    
    def initialize_copy( from )
      unless Dtective::ran?
        Dtective::run(options.scripts)
        sleep 2 # Wait for the Dtectives to head out. HACKISH.
      end
      @app = from.app
    end

    get '/__dtracy__/' do
      @probes = Dtective.probes
      @date = Time.now.strftime( "%d@%b'%y" )
      erb :index
    end

    get '/__dtracy__/updates' do
      content_type :json
      events = Dtective.events
      idx = params[:idx].to_i
      subset_events = events[idx..-1] || []
      {:idx => events.length, :data => subset_events }.to_json
    end
  end
end
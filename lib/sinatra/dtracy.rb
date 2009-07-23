require 'sinatra/base'
require 'haml'
require 'rack/contrib'
require 'json'
require 'drb'

gem 'ruby-dtrace', '>= 0.2.7'
require 'dtrace'

module Sinatra
  class Dtracy < Sinatra::Base

    set :root, File.dirname(__FILE__) + '/'
    set :raise_errors, true
    set :static, true
    set :reload, true

    use Rack::JSONP
    use Rack::Probe
    
    # TODO: Get code from a file, can be set with initialize
    # Hardcoded for now
    code = <<-DSCRIPT
    :::path
    /copyinstr((int) arg0) != "/updates"/
    {
      trace(walltimestamp); /* Seems the resulting integer is too large for Ruby */
      trace(copyinstr((int) arg0));
    }
    DSCRIPT

    class Dtective
      @@probes = []
      @@events = []
      @@bin = File.expand_path(File.dirname(__FILE__)+'/bin/dtective')
      @@port = 65000

      def self.probes
        @@probes
      end
      
      def self.events
        @@events
      end

      attr_reader :script

      DRb.start_service

      def initialize(script)
        @script = script
        @port = @@port
        DRb.start_service "druby://localhost:#{@port}", self
        @@port += 1
      end

      def run
        IO.popen("#{@@bin} #{@port}")
        puts "[ Dtracy ] Dtective reporting on port #{@port}"
      end

      def inform( events )
        @@events << events
      end

      def events
        @@events
      end

      def add_probe( probe )
        @@probes << probe
      end
    end
    
    Dtective.new(code).run
    
    get '/' do
      @probes = Dtective.probes
      haml :index
    end

    get '/updates' do
      content_type :json
      events = Dtective.events
      idx = params[:idx].to_i
      sleep 1 while idx >= (length = events.length) # Take naps until there's new data
      events = events[idx..-1] || []
      {:idx => length, :data => events }.to_json
    end
  end
end
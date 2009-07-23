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
    set :app_file, __FILE__
    set :reload, true

    use Rack::JSONP
    use Rack::Probe
    
    # TODO: Get code from a file, can be set with initialize
    # Hardcoded for now
    code = <<-DSCRIPT
    :::path
    /copyinstr((int) arg0) != "/__dtracy__/updates"/
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
    
    class Dday < Struct.new(:day, :month, :year)
      
      def initialize(now = nil)
        now ||= Time.now
        @day = now.day.to_s
        @month = Date::ABBR_MONTHNAMES[now.month].downcase
        @year = now.year.to_s[-2..-1]
      end
      
      def to_s
        @day + '@' + @month + '\'' + @year
      end
      
    end
    
    get '__dtracy__/' do
      @probes = Dtective.probes
      haml :index
    end

    get '__dtracy__/updates' do
      content_type :json
      events = Dtective.events
      idx = params[:idx].to_i
      sleep 1 while idx >= (length = events.length) # Take naps until there's new data
      events = events[idx..-1] || []
      {:idx => length, :data => events }.to_json
    end
  end
end
require 'sinatra/base'
require 'haml'
require 'rack/contrib'
require 'json'

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

    @@events = []
    @@probes = []
    
    dtracy = Dtrace.new
    dtracy.setopt('bufsize', '8m')

    # TODO: Get code from a file, can be set with initialize
    # Hardcoded for now
    code = <<-DSCRIPT
    :::path
    /copyinstr((int) arg0) != "/updates"/
    {
      trace(pid);
      trace(probemod);
      trace(probefunc);
      trace(probename); /* A given for all probes here */
      trace(copyinstr((int) arg0));
      trace(walltimestamp); /* Seems the resulting integer is too large for Ruby */
    }
    DSCRIPT

    program = dtracy.compile(code)
    dtracy.each_probe_prog(program) do |probe|
      @@probes << probe.to_s
    end
    
    program.execute
    dtracy.go 

    dtracy.buf_consumer(nil)

    Thread.new do
      loop do
        dtracy.work( proc do |data|  
          # Push in the PID
          pid = data.records[0].value
          # Push in the 4-tuple name for the probe
          name = data.records[1..3].map{|r| r.value}.join(':')
          # Anything that remains is an argument for said probe
          args = data.records[4..-2].map{|r| r.value}
          # Timestamp is tacked at the end
          ts = data.records[-1].value
          @@events << { :pid => pid, :probe => name, :arguments => args, :timestamp => ts }
        end)
      end
    end

    get '/' do
      @probes = @@probes
      haml :index
    end

    get '/updates' do
      content_type :json
      events = @@events
      idx = params[:idx].to_i
      sleep 1 while idx >= (length = events.length) # Take naps until there's new data
      events = events[idx..-1] || []
      {:idx => length, :data => events }.to_json
    end
  end
end
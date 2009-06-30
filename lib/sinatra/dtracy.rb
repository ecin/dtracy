require 'sinatra/base'
require 'haml'
require 'rack/contrib'
require 'json'
require 'dtrace'

module Sinatra
  class Dtracy < Sinatra::Base

    set :root, File.dirname(__FILE__) + '/'
    set :raise_errors, true
    set :static, true
    set :reload, true

    use Rack::JSONP
    use Rack::Probe

    run Sinatra::Dtracy

    @@events = []

    dtracy = Dtrace.new
    dtracy.setopt('bufsize', '8m')

    # TODO: Get code from a file, can be set with initialize
    # Hardcoded for now
    code = <<-DSCRIPT
    :::request
    /copyinstr((int) arg0) == "/push"/
    {
      trace(pid);
      trace(probemod);
      trace(probefunc);
      trace(probename); /* A given for all probes here */
      trace(copyinstr((int) arg0));
      trace(walltimestamp); /* Seems the resulting integer is too large for Ruby */
    }
    DSCRIPT

    dtracy.compile(code).execute
    dtracy.go 

    dtracy.buf_consumer(nil)

    Thread.new do
      loop do
        dtracy.work( proc do |data|  
          result = []
          # Push in the PID
          result << data.records[0].value
          # Push in the 4-tuple name for the probe
          result << data.records[1..3].map{|r| r.value}.join(':')
          # Anything that remains is an argument for said probe
          # Timestamp is tacked at the end
          result << data.records[5..-1].map{|r| r.value}
          result.flatten!
          @@events << { :pid => result[0], :probe => result[1], :arguments => result[2..-2], :timestamp => result[-1] }
        end)
      end
    end

    get '/' do
      haml :index
    end

    get '/updates' do
      events = @@events
      idx = params[:idx].to_i
      sleep 1 while idx >= (length = events.length) # Take naps until there's new data
      events = events[idx..-1] || []
      {:idx => length, :data => events }.to_json
    end
  end
end
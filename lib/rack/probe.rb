module Rack
  class Probe

    require 'dtrace'
    require 'dtrace/provider'
    require 'thread'

    Dtrace::Provider.create :rack do |p|
      p.probe :request, :string
    end

    @@events = []

    def self.events
      @@events
    end

    def initialize( app, opts = {} )
      @app = app

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
        while true
          begin 
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
          rescue Exception => e
            puts e
            sleep 1
            retry
          end
        end
      end
    end


    def call( env )
      request = Rack::Request.new env
      Dtrace::Probe::Rack.request { |p| p.fire(request.path) }
      @app.call env
    end

  end
end
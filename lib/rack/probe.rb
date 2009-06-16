module Rack
  class Probe
   
   require 'dtrace'
   require 'dm-core'
   require 'dm-serializer'
   require 'thread'

   DataMapper.setup(:default, 'sqlite3::memory:')
   
   class Event
     include DataMapper::Resource

     property :id, Integer, :serial => true
     property :timestamp, Integer
     property :probe, String
     property :arguments, Object # Array
   end

   Event.auto_migrate!
   
   def initialize( app, opts = {} )
     @app = app

     dtracy = Dtrace.new
     dtracy.setopt('bufsize', '8m')
     
     # Get code from a file, can be set with initialize
     code = ':::function-entry
     /copyinstr((int) arg0) == "Rack::Probe" && copyinstr((int) arg1) == "call"/
     {
       trace(probeprov);
       trace(probemod);
       trace(probefunc);
       trace(probename); /* A given for all probes here */
       trace(copyinstr((int) arg0));
       trace(copyinstr((int) arg1));
       trace(walltimestamp); /* Seems the resulting integer is too large for Ruby */
       }'

     dtracy.compile(code).execute
     dtracy.go 

     dtracy.buf_consumer(nil)

     Thread.new do
       while true 
         dtracy.work( proc do |data|  
           result = []
           result << data.records[0..3].map{|r| r.value}.join(':')
           result << data.records[4..-1].map{|r| r.value}
           result.flatten!
           Event.create :probe => result[0], :arguments => result[1..-2], :timestamp => result[-1]
         end)
       end
     end

   end
   
   def call( env )
     @app.call env
   end
    
  end
end
# Rackup File
# Run with thin -R bin/server.ru --threaded start

require File.expand_path(File.dirname(__FILE__)+'/../lib/rack/probe')
require File.expand_path(File.dirname(__FILE__)+'/../lib/sinatra/dtracy')

module Rack
  class JSONP
    alias_method :old_call, :call
    def call(env)
      old_call(env).flatten
    end
  end
end

run Sinatra::Dtracy
# Rackup File
# Run with thin -R bin/server.ru --threaded start

require File.expand_path(File.dirname(__FILE__)+'/../lib/rack/probe')
require File.expand_path(File.dirname(__FILE__)+'/../lib/sinatra/dtracy')

run Sinatra::Dtracy
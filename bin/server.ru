#!/usr/bin/env rackup -rrubygems --server thin --port 4567

require File.expand_path(File.dirname(__FILE__)+'/../lib/rack/probe')
require File.expand_path(File.dirname(__FILE__)+'/../lib/sinatra/dtracy')

run Sinatra::Dtracy
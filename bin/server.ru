#!/usr/bin/env shotgun -rrubygems --server thin --port 4567

require 'rack/contrib'
require File.expand_path(File.dirname(__FILE__)+'/../lib/rack/probe')
require File.expand_path(File.dirname(__FILE__)+'/../lib/sinatra/dtracy')

use Rack::Probe
use Rack::JSONP

run Sinatra::Dtracy
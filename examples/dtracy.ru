require File.expand_path(File.dirname(__FILE__)+'/../lib/rack/probe')
require File.expand_path(File.dirname(__FILE__)+'/../lib/sinatra/dtracy')

module Rack
  class JSONP
    def call(env)
      status, headers, response = @app.call(env)
      request = Rack::Request.new(env)
      if request.params.include?('callback')
        response = pad(request.params.delete('callback'), response)
        headers['Content-Length'] = response.length.to_s
      end
      [status, headers, response]
    end
  end
end

run Sinatra::Dtracy
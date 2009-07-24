require File.expand_path(File.dirname(__FILE__)+'/../lib/rack/probe')
require File.expand_path(File.dirname(__FILE__)+'/../lib/dtracy')

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

script = <<-DSCRIPT
:::path
/copyinstr((int) arg0) != "/__dtracy__/updates"/
{
  trace(walltimestamp); 
  trace(copyinstr((int) arg0));
}
DSCRIPT

run Dtracy::App.configure {|app| app.set :scripts, [script]}
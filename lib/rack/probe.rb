module Rack
  class Probe
    
    require 'dtrace/provider'

    Dtrace::Provider.create :rack do |p|
      p.probe :request, :string
    end

    def initialize( app, opts = {} )
      @app = app
    end

    def call( env )
      request = Rack::Request.new env
      Dtrace::Probe::Rack.request { |p| p.fire(request.path) }
      @app.call env
    end

  end
end
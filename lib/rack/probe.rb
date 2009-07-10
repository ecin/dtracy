class Symbol
  def to_proc
    Proc.new { |obj, *args| obj.send(self, *args) }
  end
end

module Rack
  class Probe
    
    gem 'ruby-dtrace', '= 0.2.7'
    require 'dtrace/provider'

    Dtrace::Provider.create :rack do |p|
      p.probe :request, :string
      p.probe :get
      p.probe :post
      p.probe :put
      p.probe :delete
      p.probe :ip,  :string
      p.probe :path,  :string
      p.probe :referer, :string
      p.probe :xhr
    end
    
    # Provider shortcut
    R = Dtrace::Probe::Rack
    
    def initialize( app, opts = {} )
      @app = app
    end

    def call( env )
      request = Rack::Request.new env
      R.get(&:fire) if request.get?
      R.post(&:fire) if request.post?
      R.put(&:fire)  if request.put?
      R.delete(&:fire) if request.delete?
      R.xhr(&:fire) if request.xhr?
      R.path    { |p| p.fire(request.path) }
      R.ip      { |p| p.fire(request.ip) }
      R.referer { |p| p.fire(request.referer) }
      @app.call env
    end

  end
end
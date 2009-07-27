require File.expand_path(File.dirname(__FILE__)+'/../spec_helper.rb')
require 'spec/interop/test'
require File.expand_path(File.dirname(__FILE__)+'/../../lib/rack/probe')
require File.expand_path(File.dirname(__FILE__)+'/../../lib/dtracy')

module Rack
  class JSONP
    alias_method :old_call, :call
    def call(env)
      old_call(env).flatten
    end
  end
end

describe Dtracy::App do
  include Rack::Test::Methods
  
  script = <<-DSCRIPT
    :::path
    /copyinstr((int) arg0) != "/__dtracy__/updates"/
    {
      trace(walltimestamp); 
      trace(copyinstr((int) arg0));
    }
    DSCRIPT
  
  Dtracy::App.configure {|app| app.set :scripts, [script]}
  
  def app
    Dtracy::App.new
  end
  
  describe 'GET /__dtracy__/' do
    
    it 'should make a javascript call to dtracy.update()' do
      get '/__dtracy__/'
      last_response.body.should match(/.*dtracy.update(.*)/)
    end
    
  end
  
  describe 'GET /__dtracy__/updates' do

    it 'should return a JSON object with an index and a data attribute' do
      get '/__dtracy__/'
      get '/__dtracy__/updates'
      response = JSON.parse(last_response.body)
      response['idx'].should_not be_nil
      response['data'].should_not be_nil
    end

    it 'should accept an index parameter to specify from which point data should be served' do
      10.times { get '/ping' }
      sleep 3 # wait for dtective setup
      get '/__dtracy__/updates?idx=5'
      JSON.parse(last_response.body)['data'].length.should == 6
    end

    it 'should return with a correct JSON mime-type' do
      get '/ping' # for current hard-coded dtrace script.
      get '/__dtracy__/updates'
      last_response['Content-Type'].should eql('application/json')
    end
    
    it 'should wrap the response in the callback param if present' do
      get '/ping'
      get '/__dtracy__/updates?callback=jsonp_function'
      last_response.should match(/jsonp_function(.*)/)
    end
    
  end
  
end
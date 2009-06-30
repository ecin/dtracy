require File.expand_path(File.dirname(__FILE__)+'/../spec_helper.rb')
require 'spec/interop/test'
require File.expand_path(File.dirname(__FILE__)+'/../../lib/rack/probe')
require File.expand_path(File.dirname(__FILE__)+'/../../lib/sinatra/dtracy')

module Rack
  class JSONP
    alias_method :old_call, :call
    def call(env)
      old_call(env).flatten
    end
  end
end

module Sinatra
  class Dtracy
    def self.empty!
      @@events = []
    end
  end
end

describe Sinatra::Dtracy do
  include Rack::Test::Methods
  
  def app
    Sinatra::Dtracy.new
  end
  
  before :each do
    Sinatra::Dtracy.empty!
  end
  
  describe 'GET /updates' do

    it 'should return a JSON object with an index and a data attribute' do
      get '/push'
      get '/updates'
      response = JSON.parse(last_response.body)
      response['idx'].should_not be_nil
      response['data'].should_not be_nil
    end

    it 'should accept an index parameter to specify from which point data should be served' do
      10.times { get '/push' }
      get '/updates?idx=5'
      JSON.parse(last_response.body)['data'].length.should == 5
    end

    it 'should return with a correct JSON mime-type' do
      get '/push' # for current hard-coded dtrace script.
      get '/updates'
      last_response['Content-Type'].should eql('application/json')
    end
    
    # There needs to be a better way to test this... 
    it 'should stall (keep connection alive) until there\'s new data to serve' do
      request = Thread.new { get '/updates' } # generates new data after one second
      request.should be_alive
      get '/push'
      sleep 3
      request.should_not be_alive
    end
    
    it 'should wrap the response in the callback param if present' do
      get '/push'
      get '/updates?callback=jsonp_function'
      last_response.should match(/jsonp_function(.*)/)
    end
    
  end

  describe 'GET /' do
    
    it 'should make a javascript call to dtracy.update()' do
      get '/'
      last_response.body.should match(/.*dtracy.update(.*)/)
    end
    
  end
  
  
end
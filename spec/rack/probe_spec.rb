require File.expand_path(File.dirname(__FILE__)+'/../spec_helper.rb')

Probe = Rack::Probe
Event = Probe::Event

describe Probe do

  describe Event do 
  
    it 'should accept a probe name, timestamp, and an array as attributes when created' do
      lambda{ Rack::Probe::Event.create  :probe => 'provider:module:function:name', 
                            :timestamp => Time.now.to_i, 
                            :arguments => [1, 'foo'] }.should_not raise_error
    end
    
  end
end
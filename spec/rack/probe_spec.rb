require File.expand_path(File.dirname(__FILE__)+'/../spec_helper.rb')
require File.expand_path(File.dirname(__FILE__)+'/../../lib/rack/probe')

require 'spec/interop/test'
require 'dtrace'

describe Rack::Probe do
  include Rack::Test::Methods
  
  def app
    a = lambda { [200, {'Content-Type' => 'text/html'},''] }
    Rack::Probe.new(a)
  end

  def compile_script(script)
    @compiler.compile(script).execute
    @compiler.go
    DtraceConsumer.new(@compiler)
  end

  class DtraceConsumer
    def finished?
      @done
    end
  end

  before :each do
    @compiler = Dtrace.new
    @compiler.setopt('bufsize', '8m')
  end

  it 'should fire a probe with a request\'s ip' do
    consumer = compile_script ":::ip {trace(copyinstr((int) arg0));}"
    get '/'
    consumer.consume_once do |d|
      record = d.data.first
      record.value.should match(/.*\..*\..*\..*/)
      consumer.finish
    end
    consumer.finished?.should be_true
  end
  
  it 'should fire a probe with a request\'s path' do
    consumer = compile_script ":::path {trace(copyinstr((int) arg0));}"
    get '/'
    consumer.consume_once do |d|
      record = d.data.first
      record.value.should eql('/')
      consumer.finish
    end
    consumer.finished?.should be_true
  end
  
  it 'should fire a probe with a request\'s referer' do
    consumer = compile_script ":::referer {trace(copyinstr((int) arg0));}"
    get '/'
    consumer.consume_once do |d|
      record = d.data.first
      record.value.should eql('/')
      consumer.finish
    end
    consumer.finished?.should be_true
  end
  
  it 'should fire a probe when a request is a GET' do
    consumer = compile_script ":::get {}"
    get '/'
    consumer.consume_once do |d|
      d.probe.name.should eql('get')
      consumer.finish
    end
    consumer.finished?.should be_true
  end
  
  it 'should fire a probe when a request is a POST' do
    consumer = compile_script ":::post {}"
    post '/'
    consumer.consume_once do |d|
      d.probe.name.should eql('post')
      consumer.finish
    end
    consumer.finished?.should be_true
  end
  
  it 'should fire a probe when a request is a PUTS' do
    consumer = compile_script ":::put {}"
    put '/'
    consumer.consume_once do |d|
      d.probe.name.should eql('put')
      consumer.finish
    end
    consumer.finished?.should be_true
  end
  
  it 'should fire a probe when a request is a DELETE' do
    consumer = compile_script ":::delete {}"
    delete '/'
    consumer.consume_once do |d|
      d.probe.name.should eql('delete')
      consumer.finish
    end
    consumer.finished?.should be_true
  end
  
  it 'should fire a probe when a request is a XHR' do
    consumer = compile_script ":::xhr {}"
    get '/', {}, { "HTTP_X_REQUESTED_WITH" => "XMLHttpRequest" }
    consumer.consume_once do |d|
      d.probe.name.should eql('xhr')
      consumer.finish
    end
    consumer.finished?.should be_true
  end

end
require 'drb'

module Dtracy
  class Dtective
    @@probes = []
    @@events = []
    @@bin = File.expand_path(File.dirname(__FILE__)+'/bin/dtective')
    @@port = 65000

    attr_reader :script
    
    DRb.start_service

    def self.probes
      @@probes
    end

    def self.events
      @@events
    end

    def self.run( scripts )
      unless @ran
        puts "[ Dtracy ] Running scripts..."
        scripts.each do |s|
          self.new(s).run
          sleep 0.1 # Apparently can't generate too many Dtrace consumers at once.
        end
        @ran = 1
      end
    end

    def self.ran?
      not @ran.nil?
    end

    def initialize(script)
      @script = script
      @port = @@port
      DRb.start_service "druby://localhost:#{@port}", self
      @@port += 1 # Missing exception handling in case a port is taken.
    end

    def run
      IO.popen("#{@@bin} #{@port}")
      puts "[ Dtracy ] Dtective reporting on port #{@port}"
    end

    def inform( events )
      @@events << events
    end

    def events
      @@events
    end

    def add_probe( probe )
      @@probes << probe
    end
  end
end
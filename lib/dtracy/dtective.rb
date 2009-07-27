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
        @ran = true
      end
    end

    def self.ran?
      not @ran.nil?
    end

    def initialize(script)
      @script = script
      @server = DRb.start_service nil, self
      p = (@server.uri =~ /:[0-9]./) + 1 # Find a neater way to do this
      @port = @server.uri[p..-1].to_i
    end

    def run
      IO.popen("#{@@bin} #{@port}")
      puts "[ Dtracy ] Dtective reporting on port #{@port}"
    end

    def inform( events )
      @@events << events
    end

    def add_probe( probe )
      @@probes << probe
    end
  end
end
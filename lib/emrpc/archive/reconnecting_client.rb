module EMRPC
  # Reconnects when needed. 
  # Timeout specifies the time interval for reconnecting attempts.
  class ReconnectingClient
    attr_reader :host, :port, :protocol, :timeout
    def initialize(options)
      @host     = options[:host]
      @port     = options[:port]
      @protocol = options[:protocol]
      @timeout  = options[:timeout]
      
      # disconnected at the start
      @connection = nil
    end
    
    def connection
      return @connection if @connection
      reset_timer
      @connection = EventMachine::connect(@host, @port, combine_protocols(@protocol, Callbacks))
    end
    
    # When connection is 100% established, we stay silent.
    def connection_completed
      cancel_timer
    end

    def unbind
      if @connection_completed 
        # connection lost during normal work, start timer
        reset_timer
        
      else 
        # connection can not be established
        
      end
      @connection = nil
      @connection_completed = false
    end
    
    def timeout!
      
    end

  private
  
    def cancel_timer
      @timer.cancel if @timer
      @timer = nil
    end
    
    def reset_timer
      cancel_timer
      @timer = EventMachine::Timer.new(@timeout, &method(:timeout!))
    end
    
    # This module is to be included into user-specified connection module.
    module Callbacks
      attr_accessor :reconnecting_client
      
      def connection_completed
        @reconnecting_client.connection_completed
        super
      end
      
      def unbind
        @reconnecting_client.unbind
        super
      end
    end # Callbacks
  
    # Combines several protocols into a single one within a new module.
    def combine_protocols(*modules)
      Module.new do
        modules.each {|m| include m }
      end
    end
    
  end # ReconnectingClient
  
  # Raised when reconnection timeout is over.
  class ReconnectionTimeout < StandardError; end
end

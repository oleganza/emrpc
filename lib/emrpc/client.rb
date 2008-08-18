module EMRPC
  class Client
    DEFAULT_TIMEOUT     = 5 # 5 sec.
    DEFAULT_PROTOCOL    = :ClientProtocol # Default EventMachine connection protocol
    DEFAULT_CONNECTIONS = 10 # 10 threads can operate concurrently
    
    attr_reader :host, :port, :protocol, :timeout, :connections
    # Create a regular object holding configuration, 
    # but returns a method proxy.
    def self.new(*args, &blk)
      client = super(*args)
      ClientProxy.new(client)
    end
    
    def initialize(options = {})
      @host     = options[:host]
      @port     = options[:port]
      @timeout  = options[:timeout] || DEFAULT_TIMEOUT
      @protocol = options[:protocol] || DEFAULT_PROTOCOL 
      @connections = Array.new(options[:connections] || DEFAULT_CONNECTIONS) do 
        ClientConnection.new(@protocol)
      end
    end
  
  end
end

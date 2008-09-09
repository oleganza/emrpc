module EMRPC
  class Client
    DEFAULT_TIMEOUT     = 5 # 5 sec.
    DEFAULT_PROTOCOL    = :ClientProtocol # Default EventMachine connection protocol
    DEFAULT_CONNECTIONS = 10 # 10 threads can operate concurrently, others will wait.
    
    attr_reader :host, :port, :protocol, :timeout, :connections
    # Create a regular object holding configuration, 
    # but return a method proxy.
    def self.new(*args, &blk)
      client = super(*args)
      backend = MultithreadedClient.new(:backends => client.connections, 
                                        :timeout => client.timeout)
      MethodProxy.new(backend)
    end
    
    def initialize(options = {})
      @host     = options[:host] or raise ":host required!"
      @port     = options[:port] or raise ":port required!"
      @timeout  = options[:timeout] || DEFAULT_TIMEOUT
      @protocol = options[:protocol] || DEFAULT_PROTOCOL 
      @connections = Array.new(options.delete(:connections) || DEFAULT_CONNECTIONS) do 
        ClientConnection.new(options)
      end
    end
  
  end
end

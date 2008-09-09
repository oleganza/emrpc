module EMRPC
  class Server
    include Util
    DEFAULT_PROTOCOL_STACK = [
      FastMessageProtocol,
      MarshalProtocol.new(Marshal),
      ServerProtocol
    ]
    attr_accessor :host, :port, :object, :protocol, :protocol_stack
    def initialize(options = {})
      @host   = options[:host]
      @port   = options[:port]
      @object = options[:object]
      @protocol = options[:protocol] || combine_modules(*( options[:protocol_stack] || DEFAULT_PROTOCOL_STACK ))
    end
    
    def run
      EventMachine.start_server(@host, @port, @protocol) do |conn|
        conn.backend = @object
      end
    end
    
  end
end

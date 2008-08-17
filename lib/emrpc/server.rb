module EMRPC
  class Server
    attr_accessor :host, :port, :object, :protocol
    def initialize(options = {})
      @host   = options[:host]
      @port   = options[:port]
      @object = options[:object]
      @protocol = options[:protocol] || ServerProtocol
    end
    
    def run
      EventMachine.start_server(@host, @port, @protocol) do |conn|
        conn.__served_object = @object
      end
    end
    
  end
end

module EMRPC
  class ClientProxy
    attr_reader :__client, :__pool
    def initialize(client, queue = Queue.new)
      @__client = client
      @__pool = queue
    end
    
    def method_name
      
    end
    
  end
end

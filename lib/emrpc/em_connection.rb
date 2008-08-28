module EMRPC
  module EmConnection
    # Connection initialization hook,
    def post_init
    end
    
    # Connection being safely established (post_init was already called).
    def connection_completed
    end
    
    # Connection was closed.
    def unbind
    end
    
    # Raw receive data callback.
    def receive_data(data)
    end
  end
end

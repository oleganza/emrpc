module EMRPC
  # call-seq:
  #   Em2Rev(MyEventMachineProtocol) -> Rev::TCPSocket
  #
  # Returns a Rev::TCPSocket subclass with protocol module and adapter module (Em2Rev) included.
  #
  def Em2Rev(em_protocol)
    Em2Rev.wrap(em_protocol)
  end
  
  # Wraps eventmachine protocol module with Rev socket callbacks
  module Em2Rev
    
    def self.wrap(em_protocol)
      wrapper = self
      Class.new(::Rev::TCPSocket) do
        include em_protocol
        include wrapper
      end
    end
    
    def initialize(*args, &blk)
      super(*args, &blk)
      post_init if respond_to?(:post_init)
    end
    
    def on_connect
      connection_completed if respond_to?(:connection_completed)
    end
    
    def on_close
      unbind if respond_to?(:unbind)
    end
    
    def on_connect_failed
      unbind if respond_to?(:unbind)
    end
    
    def on_read(data)
      receive_data(data)
    end
    
    def send_data(data)
      write(data)
    end
    
  end # Em2Rev
end # EMRPC

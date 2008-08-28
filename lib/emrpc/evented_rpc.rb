module EMRPC
  module EventedRPC
    module ServerProtocol
      attr_accessor :backend
      def post_init
      end
    
      def connection_completed
      end
    
      def unbind
        
      end
    
      def receive_message(msg)
        backend
      end
    end
    
    module ClientProtocol
      attr_accessor :callback
      def post_init
      end
    
      def connection_completed
      end
    
      def unbind
        
      end
    
      def receive_message(msg)
        
      end
    end
    
    module DefaultCallbacks
      
    end
  end
end

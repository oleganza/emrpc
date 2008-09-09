module EMRPC
  module Codec
    module Server
      include Executor
    
      # msg == [:self,  meth, *args]
      # msg == [ref_id, meth, *args]
      def receive_marshalled_message(msg)
        ref, meth, *args = msg
        backend = (ref == :self ? @backend : @ref_savior.get(ref))
        response = execute do
          backend.send(meth, *args)
        end
        send_marshalled_message(encode(backend, response))
      end
    
      def rescue_marshal_error(e)
        response = execute do
          raise e
        end
        send_marshalled_message(encode(nil, response))
      end
    
      def encode(backend, val)
        return :self if val.equal?(backend)
        begin
          Marshal.dump(val)
        rescue TypeError # undumped object
          Marshal.dump(@ref_savior.set(val))
        end
      end
    end # Server
    
    module Client
      def on_return(val)
        super decode(val)
      end
      
      def on_raise(exc)
        super decode(val)
      end
    end # Client
    
  end # Codec
end # EMRPC

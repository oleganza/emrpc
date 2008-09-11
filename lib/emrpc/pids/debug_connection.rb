module EMRPC
  module Pids
    module DebugConnection
      
      class <<self
        attr_accessor :id
      end
      self.id = 0      
      attr_accessor :id

      
      def _debug(m)
        puts "# Connection #{@id}: #{m}"
      end
      
      def post_init
        @id = (DebugConnection.id += 1)
        _debug "post_init"
        super
      end
      
      def connection_completed
        _debug "connection_completed"
        super
      end
      
      def send_handshake_message(arg)
        _debug "send_handshake_message(#{arg.inspect})"
        super
      end
      
      def receive_handshake_message(msg)
        _debug "receive_handshake_message(#{msg.inspect})"
        super
      end
      
      def receive_regular_message(msg)
        _debug "receive_regular_message(#{msg.inspect})"
        super
      end
      
      def rescue_marshal_error(e)
        _debug "rescue_marshal_error(#{e.inspect})"
        super
      end
      
      def unbind
        _debug "unbind"
        super
      end
      
    end # DebugConnection
  end # Pids
end # EMRPC

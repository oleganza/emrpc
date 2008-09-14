module EMRPC
  module EventedAPI
    module DebugPidCallbacks
      
      def _debug(m)
        puts "# Pid #{@uuid}: #{m}"
      end
          
      def connected(pid)
        _debug "connected #{pid.inspect}"
        super
      end
      
      def disconnected(pid)
        _debug "disconnected #{pid.inspect}"
        super
      end

      def connecting_failed(conn)
        _debug "connecting_failed #{conn.inspect}"
        super
      end
      
      def handshake_failed(conn, msg)
        _debug "handshake_failed #{conn.inspect} with #{msg.inspect}"
        super
      end
      
      def on_return(value)
        _debug "on_return(#{value.inspect})"
        super
      end

      def on_raise(exception)
        _debug "on_raise(#{exception.inspect})"
        super
      end
      
    end # DebugPidCallbacks
  end # EventedAPI
end # EMRPC

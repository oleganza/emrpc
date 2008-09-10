module EMRPC
  module Pids
    module DefaultCallbacks

      # Called with some pid is connected to us (we are the server)
      # or when we connect to another pid (we act as client).
      # When two pids are connected, they act as client and server interchangably
      # no matter who initiated connection.
      def connected(pid)
      end

      # Called when existing connection was lost (explicitely killed or crashed).
      # The same pid passed, as in #connected callback.
      def disconnected(pid)
      end

      # Called when pid failed connecting to the address
      # Argument +conn+ is the same what #connect(addr) returns.
      # Address is contained in the +conn.address+
      def connecting_failed(conn)
      end

      # Called when sync method returns value.
      def on_return(value)
      end

      # Called when sync method raises exception.
      def on_raise(exception)
      end

      # Called when pid responds incorrectly.
      # Normally, this should not be called.
      def handshake_failed(conn, msg)
        raise "Hello failed in connection #{conn} with message #{msg.inspect} (expected [:hello, {:uuid => <UUID>}])"
      end
      
    end # DefaultCallbacks
  end # Pids
end # EMRPC

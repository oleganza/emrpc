module EMRPC
  module EventedAPI
    # RemotePid is an interface for the actual remote pid.
    class RemotePid
      include Pid
      attr_accessor :_connection

      def initialize(conn, options)
        _common_init
        @_connection = conn
        @uuid        = options[:uuid]
      end

      def method_missing(*args)
        send(*args)
      end

      def send(*args)
        cmd = args.first
        if cmd == :kill
          return if @killed
          @killed = true
        end
        @_connection.send_raw_message(args)
      end
      
      def kill
        send(:kill)
      end
      
      def inspect
        return "#<RemotePid:#{_uid} KILLED>" if @killed
        return "#<RemotePid:#{_uid} NO CONNECTION!>" unless @_connection
        "#<RemotePid:#{_uid} on #{@_connection.address} connected with local pid #{@_connection.local_pid._uid}>"
      end
            
    end # RemotePid
  end # EventedAPI
end # EMRPC

module EMRPC
  module Pids
    class RemotePid # we don't use BlankSlate intentionally for the sake of specs passing.
      attr_accessor :_connection, :options, :killed
      attr_accessor :uuid

      def initialize(conn, options)
        @_connection = conn
        @options     = options
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
        @_connection.send_marshalled_message(args)
      end
      
      def marshal_dump
        @uuid
      end

      def marshal_load(uuid)
        @uuid = uuid
      end
      
      def inspect
        return "#<RemotePid:#{_uid} KILLED>" if @killed
        return "#<RemotePid:#{_uid} NO CONNECTION!>" unless @_connection
        "#<RemotePid:#{_uid} on #{@_connection.address} connected with local pid #{@_connection.local_pid._uid}>"
      end
      
      def _uid(uuid = @uuid)
        uuid && uuid[0,6]
      end

      def _initialize_pids_recursively_d4d309bd!(host_pid)
        pid = host_pid.find_pid(@uuid)
        initialize(pid._connection, pid.options)
      end
      
      def ==(other)
        (other.is_a?(RemotePid) || other.is_a?(Pid)) && other.uuid == @uuid
      end
      
      def killed?
        @killed
      end
    end # RemotePid
  end # Pids
end # EMRPC

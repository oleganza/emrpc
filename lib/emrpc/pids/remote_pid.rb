module EMRPC
  module Pids
    class RemotePid # we don't use blank slate intentionally < BlankSlate
      attr_accessor :_connection, :options
      attr_accessor :uuid

      def initialize(conn, options)
        @_connection = conn
        @options     = options
        @uuid        = options[:uuid]
      end

      def method_missing(*args)
        p [self, :method_missing, args]
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
        return "#<RemotePid:#{@uuid} KILLED>" if @killed
        return "#<RemotePid:#{@uuid} NO CONNECTION!>" unless @_connection
        "#<RemotePid:#{@uuid} on #{@_connection.address} connected with local pid #{@_connection.local_pid.uuid}>"
      end

      def _initialize_pids_recursively_d4d309bd!(host_pid)
        pid = host_pid.find_pid(@uuid)
        initialize(pid._connection, pid.options)
      end

    end # RemotePid
  end # Pids
end # EMRPC

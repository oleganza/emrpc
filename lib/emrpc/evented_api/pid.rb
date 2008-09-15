require 'uri'
module EMRPC
  module EventedAPI
    # Pid is a abbreviation for "process id". Pid represents so-called lightweight process (like in Erlang OTP)
    # Pids can be created, connected, disconnected, spawned, killed. 
    # When pid is created, it exists on its own.
    # When someone connects to the pid, connection is established.
    # When pid is killed, all its connections are unbinded.
    
    module Pid
      attr_accessor :uuid, :connections, :killed
      attr_accessor :_em_server_signature, :_protocol, :_bind_address
      include DefaultCallbacks
      
      # FIXME: doesn't override user-defined callbacks
      include DebugPidCallbacks if $DEBUG 
      
      # shorthand for console testing
      def self.new(*attributes)
        # We create random global const to workaround Marshal.dump issue:
        # >> Marshal.dump(Class.new.new)
        #    TypeError: can't dump anonymous class #<Class:0x5b5338>
        #
        const_set("DynamicPidClass#{rand(2**128).to_s(16).upcase}", Class.new {
          include Pid
          attr_accessor(*attributes)
        }).new
      end
      
      def initialize(*args, &blk)
        @uuid = _random_uuid
        _common_init
        super( *args, &blk) rescue nil
      end
      
      def spawn(cls, *args, &blk)
        pid = cls.new(*args, &blk)
        connect(pid)
        pid
      end
    
      def tcp_spawn(addr, cls, *args, &blk)
        pid = spawn(cls, *args, &blk)
        pid.bind(addr)
        pid
      end
      
      def bind(addr)
        raise "Pid is already binded!" if @_em_server_signature
        @_bind_address = addr.parsed_uri
        @_em_server_signature = _em_init(:start_server, @_bind_address, self)
      end
    
      # 1. Connect to the pid.
      # 2. When connection is established, asks for uuid.
      # 3. When uuid is received, triggers callback on the client.
      # (See EventedAPI::Protocol for details)
      def connect(addr, conn = nil)
        if addr.is_a?(Pid) && pid = addr
          LocalConnection.new(self, pid)
        else
          _em_init(:connect, addr, self)
        end
      end
      
      def disconnect(pid)
        @connections[pid.uuid].close_connection_after_writing
      end
      
      def kill
        return if @killed
        if @_em_server_signature
          EventMachine.stop_server(@_em_server_signature)
        end
        @connections.each do |uuid, conn|
          conn.close_connection_after_writing
        end
        @connections.clear
        @killed = true
      end
      
      # TODO:
      # When connecting to a spawned pid, we should transparantly discard TCP connection
      # in favor of local connection.
      def connection_established(pid, conn)
        @connections[pid.uuid] ||= conn
        connected(pid)
        @connections[pid.uuid].remote_pid || pid # looks like hack, but it is not.
      end

      def connection_unbind(pid, conn)
        @connections.delete(pid.uuid)
        disconnected(pid)
      end
      
      #
      # Util
      #
      
      def initialize_with_connection(conn, options)
        _common_init
        @_connection = conn
        @uuid        = options[:uuid]
      end
            
      def options
        {:uuid => @uuid}
      end
      
      def killed?
        @killed
      end
          
      def find_pid(uuid)
        ((conn = @connections[uuid]) and conn.remote_pid) or raise "Pid #{_uid} was not found in a #{self}"
      end

      def marshal_dump
        @uuid
      end
      
      def marshal_load(uuid)
        _common_init
        @uuid = uuid
      end
          
      def connection_uuids
        (@connections || {}).keys
      end
    
      def inspect
        return "#<Pid:#{_uid} KILLED>" if @killed
        "#<Pid:#{_uid} connected to #{connection_uuids.map{|u|_uid(u)}.inspect}>"
      end
    
      def ==(other)
        other.is_a?(Pid) && other.uuid == @uuid
      end
      
      # shorter uuid for pretty output
      def _uid(uuid = @uuid)
        uuid && uuid[0,6]
      end
    
      #
      # Private, but accessible from outside methods are prefixed with underscore.
      #
      
      # common start_server/connect pattern for eventmachine.
      def _em_init(method, addr, pid)
        addr = addr.parsed_uri
        EventMachine.__send__(method, addr.host, addr.port, _protocol) do |conn|
          conn.local_pid = pid
          conn.address = addr
        end
      end
      
      def _protocol
        @_protocol ||= self.__send__(:_protocol=, RemoteConnection)
      end
      
      def _protocol=(p)
        @_protocol = Util.combine_modules(
          p, 
          MarshalProtocol.new(Marshal), 
          FastMessageProtocol, 
          $DEBUG ? DebugConnection : Module.new
        )
      end
      
      def _send_dirty(*args)
        args._initialize_pids_recursively_d4d309bd!(self)
        send(*args)
      end
        
      def _initialize_pids_recursively_d4d309bd!(host_pid)
        pid = host_pid.find_pid(@uuid)
        initialize_with_connection(pid._connection, pid.options)
      end
      
    private
  
      def _common_init
        @connections = {} # pid.uuid -> connection
      end
      
      def _random_uuid
        # FIXME: insert real uuid generating here!
        rand(2**128).to_s(16)
      end
      
    end # Pid
  end # EventedAPI
end # EMRPC

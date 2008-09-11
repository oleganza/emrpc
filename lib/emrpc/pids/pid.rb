require 'uri'
module EMRPC
  module Pids
    module Pid
      attr_accessor :uuid, :connected_pids, :killed
      attr_accessor :_em_server_signature, :_protocol, :_bind_address
      include DefaultCallbacks
      
      # FIXME: doesn't override user-defined callbacks
      include DebugPidCallbacks if $DEBUG 
      
      # shorthand for console testing
      def self.new(*attributes)
        Class.new do
          include Pid
          attr_accessor(*attributes)
        end.new
      end
      
      def initialize(*args, &blk)
        @uuid = _random_uuid
        @connected_pids = {}
        super( *args, &blk) rescue nil
      end
      
      def initialize_with_connection(conn, options)
        @connected_pids = {}
        @_connection = conn
        @uuid        = options[:uuid]
      end
    
      def options
        {:uuid => @uuid}
      end
    
      def spawn(cls, *args, &blk)
        pid = cls.new(*args, &blk)
        _register_pid(pid)
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
      # (See Pids::Protocol for details)
      def connect(addr)
        _em_init(:connect, addr, self)
      end
      
      def kill
        return if @killed
        if @_em_server_signature
          EventMachine.stop_server(@_em_server_signature)
        end
        @connected_pids.each do |uuid, pid|
          pid.send(:disconnected,self)
        end
        @connected_pids.clear
        @killed = true
      end
      
      def killed?
        @killed
      end
          
      def find_pid(uuid)
        @connected_pids[uuid] or raise "No pid #{uuid} found in a #{self}"
      end

      def marshal_dump
        @uuid
      end
      
      def marshal_load(uuid)
        @uuid = uuid
      end
          
      def connection_uuids
        (@connected_pids || {}).keys
      end
    
      def inspect
        return "#<Pid:#{_uid} KILLED>" if @killed
        "#<Pid:#{_uid} connected to #{connection_uuids.map{|u|_uid(u)}.inspect}>"
      end
    
      def ==(other)
        (other.is_a?(RemotePid) || other.is_a?(Pid)) && other.uuid == @uuid
      end
      
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
        @_protocol ||= self.__send__(:_protocol=, Protocol)
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
  
      def _register_pid(pid)
        @connected_pids[pid.uuid] ||= pid
      end
    
      def _unregister_pid(pid)
        @connected_pids.delete(pid.uuid)
      end
      
      def _initialize_pids_recursively_d4d309bd!(host_pid)
        pid = host_pid.find_pid(@uuid)
        initialize_with_connection(pid._connection, pid.options)
      end
      
    private
  
      def _random_uuid
        # FIXME: insert real uuid generating here!
        rand(2**128).to_s(16)
      end
      
    end # Pid
  end # Pids
end # EMRPC

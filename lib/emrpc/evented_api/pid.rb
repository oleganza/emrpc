require 'uri'
module EMRPC  
  # Pid is a abbreviation for "process id". Pid represents so-called lightweight process (like in Erlang OTP)
  # Pids can be created, connected, disconnected, spawned, killed. 
  # When pid is created, it exists on its own.
  # When someone connects to the pid, connection is established.
  # When pid is killed, all its connections are unbinded.
  
  module Pid
    attr_accessor :uuid, :connections, :killed, :options
    attr_accessor :_em_server_signature, :_protocol, :_bind_address
    include DefaultCallbacks
    include ProtocolMapper
    
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
      @options = {:uuid => @uuid}
      _common_init
      super(*args, &blk) rescue nil
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
    
    def thread_spawn(cls, *args, &blk)
      # TODO: think about thread-safe passing messages back to sender.
    end
    
    def bind(addr)
      raise "Pid is already binded!" if @_em_server_signature
      @_bind_address = addr.parsed_uri
      this = self
      @_em_server_signature = make_server_connection(@_bind_address, _protocol)  do |conn|
        conn.local_pid = this
        conn.address = addr
      end
    end
  
    # 1. Connect to the pid.
    # 2. When connection is established, asks for uuid.
    # 3. When uuid is received, triggers callback on the client.
    # (See Protocol for details)
    def connect(addr, connected_callback = nil, disconnected_callback = nil)
      c = if addr.is_a?(Pid) && pid = addr
        LocalConnection.new(self, pid)
      else
        this = self
        make_client_connection(addr, _protocol)  do |conn|
          conn.local_pid = this
          conn.address = addr
        end
      end
      c.connected_callback    = connected_callback
      c.disconnected_callback = disconnected_callback
      c
    end
    
    def disconnect(pid, disconnected_callback = nil)
      c = @connections[pid.uuid]
      c.disconnected_callback = disconnected_callback if disconnected_callback
      c.close_connection_after_writing
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
      __send__(conn.connected_callback, pid)
      @connections[pid.uuid].remote_pid || pid # looks like hack, but it is not.
    end

    def connection_unbind(pid, conn)
      @connections.delete(pid.uuid)
      __send__(conn.disconnected_callback, pid)
    end
    
    #
    # Util
    # 
    def options=(opts)
      @options = opts
      @options[:uuid] = @uuid
      @options
    end
    
    def killed?
      @killed
    end
        
    def find_pid(uuid)
      return self if uuid == @uuid
      ((conn = @connections[uuid]) and conn.remote_pid) or raise "Pid #{_uid} was not found in a #{self.inspect}"
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
    
    def pid_class_name
      "Pid"
    end
    
    def inspect
      return "#<#{pid_class_name}:#{_uid} KILLED>" if @killed
      "#<#{pid_class_name}:#{_uid} connected to #{connection_uuids.map{|u|_uid(u)}.inspect}>"
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
    
    # TODO: remove this in favor of using codec.rb
    def _send_dirty(*args)
      args._initialize_pids_recursively_d4d309bd!(self)
      send(*args)
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
end # EMRPC

require 'uri'
module EMRPC
  module Pids
    module Pid
      attr_accessor :uuid, :options, :connected_pids, :killed
      attr_accessor :_em_server_signature, :_protocol
      include DefaultCallbacks
    
      def initialize(*args, &blk)
        @uuid = _random_uuid
        @connected_pids = {}
        super( *args, &blk) rescue nil
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
        pid._em_server_signature = _em_init(:start_server, addr, pid)
        pid
      end
    
      # 1. Connect to the pid.
      # 2. When connection is established, asks for uuid.
      # 3. When uuid is received, triggers callback on the client.
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
    
      def connection_uuids
        @connected_pids.keys
      end
    
      def inspect
        return "#<Pid:#{@uuid} KILLED>" if @killed
        "#<Pid:#{@uuid} connected to #{connection_uuids.inspect}>"
      end
    
      #
      # Private, but accessible from outside methods are prefixed with underscore.
      #
      
      # common start_server/connect pattern for eventmachine.
      def _em_init(method, addr, pid)
        addr = URI.parse(addr) unless addr.is_a?(URI::Generic)
        EventMachine.__send__(method, addr.host, addr.port, _protocol) do |conn|
          conn.local_pid = pid
          conn.address = addr
        end
      end
      
      def _protocol
        @_protocol ||= self.__send__(:_protocol=, Protocol)
      end
      
      def _protocol=(p)
        @_protocol = Util.combine_modules(p, MarshalProtocol.new(Marshal))
      end
      
      def _send_dirty(*args)
        args._initialize_pids_recursively_d4d309bd!(self)
        send(*args)
      end
  
      def _register_pid(pid)
        @connected_pids[pid.uuid] = pid
      end
    
      def _unregister_pid(pid)
        @connected_pids.delete(pid.uuid)
      end
      
    private
  
      def _random_uuid
        # FIXME: insert real uuid generating here!
        rand(2**128).to_s(16)
      end
      
    end # Pid
  end # Pids
end # EMRPC

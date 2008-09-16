module EMRPC
  class LocalConnection
    class Channel
      attr_accessor :conn12, :conn21
      def initialize(pid1, pid2, conn12 = nil)
        @conn21 = LocalConnection.new(pid2, pid1, self)
        @conn12 = conn12 || LocalConnection.new(pid1, pid2, self)
      end
      def unbind
        @conn12.unbind
        @conn21.unbind
      end
      def connection
        @conn12
      end
    end
    
    attr_accessor :local_pid
    attr_accessor :remote_pid
    attr_accessor :channel
    
    def initialize(local_pid, remote_pid, channel = nil)
      @channel = channel || Channel.new(local_pid, remote_pid, self)
      @local_pid = local_pid
      @remote_pid = local_pid.connection_established(remote_pid, self)
    end
    
    def unbind
      lpid = @local_pid
      rpid = @remote_pid
      @local_pid = nil
      @remote_pid = nil
      lpid.connection_unbind(rpid, self)
    end
    
    def close_connection
      @channel.unbind
    end
    alias close_connection_after_writing close_connection
          
    LOCALNODE_ADDRESS = 'emrpc://localnode/'.parsed_uri.freeze
    def address
      LOCALNODE_ADDRESS
    end
    
  end # LocalConnection
end # EMRPC

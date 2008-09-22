module EMRPC
  module ConnectionMixin
    attr_accessor :local_pid, :remote_pid
    attr_accessor :connected_callback, :disconnected_callback
    
    def connected_callback
      @connected_callback || :connected
    end

    def disconnected_callback
      @disconnected_callback || :disconnected
    end
  end
end
